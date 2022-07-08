# frozen_string_literal: true

require_relative "local_assets_base"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionLocalAssets < LocalAssetsBase
        EXT_ASSET_REGEX = %r{(http:|https:)?//cdn\.shopify\.com/extensions/.+?/(assets/.+?\.(?:css|js))}

        def initialize(ctx, app, extension:)
          super(ctx, app)
          @extension = extension
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(EXT_ASSET_REGEX) do |match|
            path = Regexp.last_match[2]
            if @extension.static_asset_paths.include?(path) # && @extension.id == 1234 # TODO
              "/#{path}"
            else
              match
            end
          end

          [replaced_body]
        end

        def serve_file(path_info)
          path = @extension.root.join(path_info[1..-1])
          if path.file? && path.readable? && @extension.static_asset_file?(path)
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
