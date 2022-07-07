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

        def initialize(ctx, app)
          @ctx = ctx
          @app = app
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

        def serve_file(_path_info)
          raise "#{self.class.name}#serve_file(path_info) must be defined"
        end

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

        def replace_asset_urls(_body)
          raise "#{self.class.name}#replace_asset_urls(body) must be defined!"
        end
      end
    end
  end
end
