# frozen_string_literal: true

module ShopifyCli
  module Theme
    module DevServer
      class HotReload
        def initialize(app, theme, watcher)
          @app = app
          @theme = theme
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

        def notify_streams_of_file_change(modified, added, _removed)
          files = (modified + added).reject { |file| @theme.ignore?(file) }
            .map { |file| @theme[file].relative_path }

          @streams.broadcast(JSON.generate(
            modified: files,
          ))

          puts "[HotReload] Modified #{files.join(", ")}" if ThemeDevServer.debug
        end

        private

        def request_is_html?(headers)
          headers["content-type"]&.start_with?("text/html")
        end

        def inject_hot_reload_javascript(body)
          hot_reload_js = File.read("#{__dir__}/hot-reload.js")
          hot_reload_script = "<script>\n#{hot_reload_js}</script>"
          body = body.join.gsub("</body>", "#{hot_reload_script}\n</body>")

          [body]
        end

        def create_stream
          stream = @streams.new

          puts "[HotReload] Connected to SSE stream" if ThemeDevServer.debug

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
