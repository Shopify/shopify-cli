# frozen_string_literal: true

require_relative "local_assets_base"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionLocalAssets < LocalAssetsBase
        URL_REGEX = %r{(http:|https:)?//cdn\.shopify\.com/extensions/.+?/(assets/.+?\.(?:css|js))}

        def initialize(ctx, app, extension:)
          super(ctx, app, target: extension)
          @base_regex = /<(script|link).*?data-app-id=\"#{extension.id}\".*?>/
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(@base_regex) do |asset_tag|
            asset_tag.gsub(URL_REGEX) do |url|
              path = Regexp.last_match[2]
              if @target.static_asset_paths.include?(path)
                "/#{path}"
              else
                url
              end
            end
          end
          [replaced_body]
        end
      end
    end
  end
end
