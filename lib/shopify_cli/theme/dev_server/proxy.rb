# frozen_string_literal: true
require "net/http"
require "stringio"
require "time"
require "cgi"
require_relative "proxy/template_param_builder"

module ShopifyCLI
  module Theme
    module DevServer
      HOP_BY_HOP_HEADERS = [
        "connection",
        "keep-alive",
        "proxy-authenticate",
        "proxy-authorization",
        "te",
        "trailer",
        "transfer-encoding",
        "upgrade",
        "content-security-policy",
      ]

      class Proxy
        SESSION_COOKIE_NAME = "_secure_session_id"
        SESSION_COOKIE_REGEXP = /#{SESSION_COOKIE_NAME}=(\h+)/
        SESSION_COOKIE_MAX_AGE = 60 * 60 * 23 # 1 day - leeway of 1h

        def initialize(ctx, theme:, syncer:)
          @ctx = ctx
          @theme = theme
          @syncer = syncer
          @core_endpoints = Set.new

          @secure_session_id = nil
          @last_session_cookie_refresh = nil
        end

        def call(env)
          headers = extract_http_request_headers(env)
          headers["Host"] = @theme.shop
          headers["Cookie"] = add_session_cookie(headers["Cookie"])
          headers["Accept-Encoding"] = "none"
          headers["User-Agent"] = "Shopify CLI"

          query = URI.decode_www_form(env["QUERY_STRING"])
          replace_templates = build_replace_templates_param(env)
          response = if replace_templates.any?
            # Pass to SFR the recently modified templates in `replace_templates` body param
            headers["Authorization"] = "Bearer #{bearer_token}"
            form_data = URI.decode_www_form(env["rack.input"].read).to_h
            request(
              "POST", env["PATH_INFO"],
              headers: headers,
              query: query,
              form_data: form_data.merge(replace_templates).merge(_method: env["REQUEST_METHOD"]),
            )
          else
            request(
              env["REQUEST_METHOD"], env["PATH_INFO"],
              headers: headers,
              query: query,
              body_stream: (env["rack.input"] if has_body?(headers)),
            )
          end

          headers = get_response_headers(response)

          unless headers["x-storefront-renderer-rendered"]
            @core_endpoints << env["PATH_INFO"]
          end

          body = patch_body(env, response.body)
          body = [body] unless body.respond_to?(:each)
          [response.code, headers, body]
        end

        private

        def patch_body(env, body)
          return [""] unless body

          body.gsub(%r{(data-.+=(["']))(http:|https:)?//#{@theme.shop}(.*)(\2)}) do |_|
            match = Regexp.last_match
            "#{match[1]}http://#{host(env)}#{match[4]}#{match[5]}"
          end
        end

        def host(env)
          env["HTTP_HOST"]
        end

        def has_body?(headers)
          headers["Content-Length"] || headers["Transfer-Encoding"]
        end

        def bearer_token
          ShopifyCLI::DB.get(:storefront_renderer_production_exchange_token) ||
            raise(KeyError, "storefront_renderer_production_exchange_token missing")
        end

        def extract_http_request_headers(env)
          headers = HeaderHash.new

          env.each do |name, value|
            next if value.nil?

            if /^HTTP_[A-Z0-9_]+$/.match?(name) || name == "CONTENT_TYPE" || name == "CONTENT_LENGTH"
              headers[reconstruct_header_name(name)] = value
            end
          end

          x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")
          headers["X-Forwarded-For"] = x_forwarded_for

          headers
        end

        def normalize_headers(headers)
          mapped = headers.map do |k, v|
            [k, v.is_a?(Array) ? v.join("\n") : v]
          end
          HeaderHash.new(Hash[mapped])
        end

        def reconstruct_header_name(name)
          name.sub(/^HTTP_/, "").gsub("_", "-")
        end

        def build_replace_templates_param(env)
          TemplateParamBuilder.new
            .with_core_endpoints(@core_endpoints)
            .with_syncer(@syncer)
            .with_theme(@theme)
            .with_rack_env(env)
            .build
        end

        def add_session_cookie(cookie_header)
          cookie_header = if cookie_header
            cookie_header.dup
          else
            +""
          end

          expected_session_cookie = "#{SESSION_COOKIE_NAME}=#{secure_session_id}"

          unless cookie_header.include?(expected_session_cookie)
            if cookie_header.include?(SESSION_COOKIE_NAME)
              cookie_header.sub!(SESSION_COOKIE_REGEXP, expected_session_cookie)
            else
              cookie_header << "; " unless cookie_header.empty?
              cookie_header << expected_session_cookie
            end
          end

          cookie_header
        end

        def secure_session_id_expired?
          return true unless @secure_session_id && @last_session_cookie_refresh
          Time.now - @last_session_cookie_refresh >= SESSION_COOKIE_MAX_AGE
        end

        def extract_secure_session_id_from_response_headers(headers)
          return unless headers["set-cookie"]
          headers["set-cookie"][SESSION_COOKIE_REGEXP, 1]
        end

        def secure_session_id
          if secure_session_id_expired?
            @ctx.debug("Refreshing preview _secure_session_id cookie")
            response = request("HEAD", "/", query: [[:preview_theme_id, @theme.id]])
            @secure_session_id = extract_secure_session_id_from_response_headers(response)
            @last_session_cookie_refresh = Time.now
          end

          @secure_session_id
        end

        def get_response_headers(response)
          response_headers = normalize_headers(
            response.respond_to?(:headers) ? response.headers : response.to_hash
          )
          # According to https://tools.ietf.org/html/draft-ietf-httpbis-p1-messaging-14#section-7.1.3.1Acc
          # should remove hop-by-hop header fields
          # (Taken from Rack::Proxy)
          response_headers.reject! { |k| HOP_BY_HOP_HEADERS.include?(k.downcase) }

          if response_headers["location"]&.include?("myshopify.com")
            response_headers["location"].gsub!(%r{(https://#{@theme.shop})}, "http://127.0.0.1:9292")
          end

          new_session_id = extract_secure_session_id_from_response_headers(response_headers)
          if new_session_id
            @ctx.debug("New _secure_session_id cookie from response")
            @secure_session_id = new_session_id
            @last_session_cookie_refresh = Time.now
          end

          response_headers
        end

        def request(method, path, headers: nil, query: [], form_data: nil, body_stream: nil)
          uri = URI.join("https://#{@theme.shop}", path)
          uri.query = URI.encode_www_form(query + [[:_fd, 0], [:pb, 0]])

          @ctx.debug("Proxying #{method} #{uri}")

          Net::HTTP.start(uri.host, 443, use_ssl: true) do |http|
            req_class = Net::HTTP.const_get(method.capitalize)
            req = req_class.new(uri)
            req.initialize_http_header(headers) if headers
            req.set_form_data(form_data) if form_data
            req.body_stream = body_stream if body_stream
            response = http.request(req)
            @ctx.debug("`-> #{response.code} request_id: #{response["x-request-id"]}")
            response
          end
        end
      end
    end
  end
end
