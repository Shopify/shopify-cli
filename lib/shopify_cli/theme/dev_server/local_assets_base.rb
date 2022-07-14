# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class LocalAssetsBase
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

        def initialize(ctx, app, target:)
          @ctx = ctx
          @app = app
          @target = target
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

        def serve_fail(status, body)
          [
            status,
            {
              "Content-Type" => "text/plain",
              "Content-Length" => body.size.to_s,
            },
            [body],
          ]
        end

        def serve_file(path_info)
          path = @target.root.join(path_info[1..-1])
          if path.file? && path.readable? && @target.static_asset_file?(path)
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
