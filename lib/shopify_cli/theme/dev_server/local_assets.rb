# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class LocalAssets
        ASSET_REGEX = %r{//cdn\.shopify\.com/s/.+?/(assets/.+?\.(?:css|js))}

        class FileBody
          def initialize(path)
            @path = path
          end

          # Naive implementation. Only used in unit tests.
          def each
            yield @path.read
          end

          # Rack will stream a body that responds to `to_path`
          def to_path
            @path.to_path
          end
        end

        def initialize(ctx, app, theme:)
          @ctx = ctx
          @app = app
          @theme = theme
        end

        def call(env)
          if env["PATH_INFO"].start_with?("/assets")
            # Serve from disk
            serve_file(env["PATH_INFO"])
          else
            # Proxy the request, and replace the URLs in the response
            status, headers, body = @app.call(env)
            body = replace_asset_urls(body)
            [status, headers, body]
          end
        end

        private

        def serve_file(path_info)
          path = @theme.root.join(path_info[1..-1])
          if path.file? && path.readable?
            [
              200,
              {
                "Content-Type" => MimeType.by_filename(path).to_s,
                "Content-Length" => path.size.to_s,
              },
              FileBody.new(path),
            ]
          else
            fail(404, "Not found")
          end
        end

        def fail(status, body)
          [
            status,
            {
              "Content-Type" => "text/plain",
              "Content-Length" => body.size.to_s,
            },
            [body],
          ]
        end

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(ASSET_REGEX) do |match|
            path = Pathname.new(Regexp.last_match[1])
            if @theme.static_asset_paths.include?(path)
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
