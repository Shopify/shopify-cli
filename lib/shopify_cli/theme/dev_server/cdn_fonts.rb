# frozen_string_literal: true

require_relative "cdn/cdn_helper"

module ShopifyCLI
  module Theme
    module DevServer
      class CdnFonts
        include Cdn::CdnHelper

        FONTS_PATH = "/fonts"
        FONTS_CDN = "https://fonts.shopifycdn.com"
        FONTS_REGEX = %r{#{FONTS_CDN}}

        def initialize(app, theme:)
          @app = app
          @theme = theme
        end

        def call(env)
          path = env["PATH_INFO"]

          # Serve from fonts CDN
          return serve_font(env, path) if path.start_with?(FONTS_PATH)

          # Proxy the request, and replace the URLs in the response
          status, headers, body = @app.call(env)
          body = replace_font_urls(body)
          [status, headers, body]
        end

        private

        def serve_font(env, path)
          query = env["QUERY_STRING"]
          uri = fonts_cdn_uri(path, query)

          proxy_request(env, uri, @theme)
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
