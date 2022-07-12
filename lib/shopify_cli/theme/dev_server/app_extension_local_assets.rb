# frozen_string_literal: true

require_relative "local_assets_base"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionLocalAssets < LocalAssetsBase
        TAE_ASSET_REGEX = %r{(http:|https:)?//cdn\.shopify\.com/extensions/.+?/(assets/.+?\.(?:css|js))}

        def initialize(ctx, app, extension:)
          super(ctx, app, target: extension)
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(TAE_ASSET_REGEX) do |match|
            path = Regexp.last_match[2]
            if @target.static_asset_paths.include?(path)
              "/#{path}"
            else
              match
            end
          end

          [replaced_body]
        end
      end
    end
  end
end
