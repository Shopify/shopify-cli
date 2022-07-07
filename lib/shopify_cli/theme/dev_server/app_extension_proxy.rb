# frozen_string_literal: true
require "net/http"
require_relative "base_proxy"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionProxy < BaseProxy
        def initialize(ctx, extension:, theme:)
          super(ctx)

          @extension = extension
          @shop = theme.shop
          @theme_id = theme.id
        end

        def call(env)
          headers = super(env)
          query = URI.decode_www_form(env["QUERY_STRING"])
          replace_templates = build_replacement_param(env)
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

        def build_replacement_param(_env)
          []
        end
      end
    end
  end
end
