# frozen_string_literal: true

require_relative "cdn/cdn_helper"
require_relative "local_assets"

module ShopifyCLI
  module Theme
    module DevServer
      class CdnAssets
        include Cdn::CdnHelper

        ASSETS_PROXY_PATH = "/cdn_asset"
        ASSETS_CDN = "//cdn.shopify.com"
        ASSETS_CDN_REGEX = %r{((https?:)?#{ASSETS_CDN}(.*\.(css|js|map)))}
        ASSETS_SOURCE_MAP_REGEX = /\/[\/|\*]# sourceMappingURL\=(\/.*)/

        def initialize(app, theme:)
          @app = app
          @theme = theme
        end

        def call(env)
          path = env["PATH_INFO"]

          # Serve assets from CDN
          return serve_asset(env, path) if path.start_with?(ASSETS_PROXY_PATH)

          # Proxy the request, and replace the URLs in the response
          status, headers, body = @app.call(env)
          body = replace_asset_urls(body)
          [status, headers, body]
        end

        private

        def serve_asset(env, path)
          path = path.gsub(%r{^#{ASSETS_PROXY_PATH}}, "")
          query = env["QUERY_STRING"]
          uri = asset_cdn_uri(path, query)

          status, headers, body = proxy_request(env, uri, @theme)

          [status, headers, replace_source_map_url(body)]
        end

        def asset_cdn_uri(path, query)
          uri = URI.join("https:#{ASSETS_CDN}", path)
          uri.query = query.split("&").last
          uri
        end

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(ASSETS_CDN_REGEX) do |match|
            if local_asset?(match)
              match
            else
              match.gsub(%r{(https?:)?#{ASSETS_CDN}}, ASSETS_PROXY_PATH)
            end
          end

          [replaced_body]
        end

        def replace_source_map_url(body)
          body_content = body.join
          map_regex_match = body_content.match(ASSETS_SOURCE_MAP_REGEX)
          return body if map_regex_match.nil?

          map_url = map_regex_match[1]
          return body if map_url.nil?

          [body_content.gsub(map_url, "#{ASSETS_PROXY_PATH}#{map_url}")]
        end

        def local_asset?(path)
          match = path.match(LocalAssets::ASSET_REGEX)
          return false if match.nil?

          path = Pathname.new(match[1])
          @theme.static_asset_paths.include?(path)
        end
      end
    end
  end
end
