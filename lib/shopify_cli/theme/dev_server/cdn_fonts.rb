# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class CdnFonts
        FONTS_PATH = "/fonts"
        FONTS_CDN = "https://fonts.shopifycdn.com/assistant"
        FONTS_REGEX = %r{#{FONTS_CDN}}

        def initialize(app, theme:)
          @app = app
          @theme = theme
        end

        def call(env)
          path = env["PATH_INFO"]

          # Serve from fonts CDN
          return serve_font(env) if path.start_with?(FONTS_PATH)

          # Proxy the request, and replace the URLs in the response
          status, headers, body = @app.call(env)
          body = replace_font_urls(body)
          [status, headers, body]
        end

        private

        def serve_font(env)
          parameters = %w(PATH_INFO QUERY_STRING REQUEST_METHOD rack.input)
          path, query, method, body_stream = *env.slice(*parameters).values

          uri = fonts_cdn_uri(path, query)

          response = Net::HTTP.start(uri.host, 443, use_ssl: true) do |http|
            req_class = Net::HTTP.const_get(method.capitalize)
            req = req_class.new(uri)
            req.initialize_http_header(fonts_cdn_headers)
            req.body_stream = body_stream
            http.request(req)
          end

          [
            response.code.to_s,
            {
              "Content-Type" => response.content_type,
              "Content-Length" => response.content_length.to_s,
            },
            [response.body],
          ]
        end

        def fonts_cdn_headers
          {
            "Referer" => "https://#{@theme.shop}",
            "Transfer-Encoding" => "chunked",
          }
        end

        def fonts_cdn_uri(path, query)
          uri = URI.join("#{FONTS_CDN}/", path.gsub(%r{^#{FONTS_PATH}\/}, ""))
          uri.query = query.split("&").last
          uri
        end

        def replace_font_urls(body)
          [body.join.gsub(FONTS_REGEX, FONTS_PATH)]
        end
      end
    end
  end
end
