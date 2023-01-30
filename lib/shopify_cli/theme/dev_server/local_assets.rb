# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      class LocalAssets
        THEME_REGEX = %r{//cdn\.shopify\.com/s/.+?/(assets/.+?\.(?:css|js))}

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

        def initialize(ctx, app, target)
          @ctx = ctx
          @app = app
          @target = target
        end

        def call(env)
          path_info = env["PATH_INFO"]
          if path_info.start_with?("/assets")
            # Serve from disk
            serve_file(path_info)
          else
            # Proxy the request, and replace the URLs in the response
            status, headers, body = @app.call(env)
            body = replace_asset_urls(body) unless path_info.start_with?("/fonts")
            [status, headers, body]
          end
        end

        private

        def replace_asset_urls(body)
          replaced_body = body.join.gsub(THEME_REGEX) do |match|
            path = Regexp.last_match[1]
            if @target.static_asset_paths.include?(path)
              "/#{path}"
            else
              match
            end
          end

          [replaced_body]
        rescue ArgumentError => error
          return [body.join] if error.message.include?("invalid byte sequence")

          raise error
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
