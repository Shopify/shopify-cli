# frozen_string_literal: true

require_relative "local_assets_base"

module ShopifyCLI
  module Theme
    module DevServer
      class ThemeLocalAssets < LocalAssetsBase
        URL_REGEX = %r{//cdn\.shopify\.com/s/.+?/(assets/.+?\.(?:css|js))}

        def initialize(ctx, app, theme:)
          super(ctx, app, target: theme)
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(URL_REGEX) do |match|
            path = Regexp.last_match[1]
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
