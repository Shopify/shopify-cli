# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        def initialize(ctx, app, theme:, watcher:, mode:, ignore_filter: nil)
          @ctx = ctx
          @app = app
          @theme = theme
          @mode = mode
          @streams = SSE::Streams.new
          @watcher = watcher
          @watcher.add_observer(self, :notify_streams_of_file_change)
          @ignore_filter = ignore_filter
        end

        def call(env)
          if env["PATH_INFO"] == "/hot-reload"
            create_stream
          else
            status, headers, body = @app.call(env)

            body = inject_hot_reload_javascript(body) if request_is_html?(headers)

            [status, headers, body]
          end
        end

        def close
          @streams.close
        end

        def notify_streams_of_file_change(modified, added, _removed)
          files = (modified + added).reject { |file| @ignore_filter&.ignore?(file) }
            .map { |file| @theme[file].relative_path }

          unless files.empty?
            @streams.broadcast(JSON.generate(modified: files))
            @ctx.debug("[HotReload] Modified #{files.join(", ")}")
          end
        end

        private

        def request_is_html?(headers)
          headers["content-type"]&.start_with?("text/html")
        end

        def inject_hot_reload_javascript(body)
          hot_reload_js = ::File.read("#{__dir__}/hot-reload.js")
          hot_reload_script = [
            "<script>",
            params_js,
            hot_reload_js,
            "</script>",
          ].join("\n")

          body = body.join.gsub("</body>", "#{hot_reload_script}\n</body>")

          [body]
        end

        def params_js
          env = { mode: @mode }
          <<~JS
            (() => {
              window.__SHOPIFY_CLI_ENV__ = #{env.to_json};
            })();
          JS
        end

        def create_stream
          stream = @streams.new

          @ctx.debug("[HotReload] Connected to SSE stream")

          [
            200,
            {
              "Content-Type" => "text/event-stream",
              "Cache-Control" => "no-cache",
              "webrick.chunked" => true,
            },
            stream,
          ]
        end
      end
    end
  end
end
