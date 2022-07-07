# frozen_string_literal: true

require_relative "local_assets_base"

module ShopifyCLI
  module Theme
    module DevServer
      class ThemeLocalAssets < LocalAssetsBase
        THEME_REGEX = %r{//cdn\.shopify\.com/s/.+?/(assets/.+?\.(?:css|js))}

        def initialize(ctx, app, theme:)
          super(ctx, app)
          @theme = theme
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(THEME_REGEX) do |match|
            path = Regexp.last_match[1]
            if @theme.static_asset_paths.include?(path)
              "/#{path}"
            else
              match
            end
          end

          [replaced_body]
        end

        def serve_file(path_info)
          path = @theme.root.join(path_info[1..-1])
          if path.file? && path.readable? && @theme.static_asset_file?(path)
            [
              200,
              {
                "Content-Type" => MimeType.by_filename(path).to_s,
                "Content-Length" => path.size.to_s,
              },
              FileBody.new(path),
            ]
          else
            serve_fail(404, "Not found")
          end
        end
      end
    end
  end
end
