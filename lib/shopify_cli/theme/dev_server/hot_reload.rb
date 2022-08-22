# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      class HotReload
        def initialize(ctx, app, broadcast_hooks: [], js_hook: nil, watcher:, mode:)
          @ctx = ctx
          @app = app
          @mode = mode
          @broadcast_hooks = broadcast_hooks
          @js_hook = js_hook
          @streams = SSE::Streams.new
          @watcher = watcher
          @watcher.add_observer(self, :notify_streams_of_file_change)
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

        def notify_streams_of_file_change(modified, added, removed)
          @broadcast_hooks.each do |hook|
            hook.call(modified, added, removed, streams: @streams)
          end
        end

        private

        def request_is_html?(headers)
          headers["content-type"]&.start_with?("text/html")
        end

        def inject_hot_reload_javascript(body)
          @js_hook&.call(body: body, dir: __dir__, mode: @mode)
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
