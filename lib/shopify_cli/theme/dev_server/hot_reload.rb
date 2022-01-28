# frozen_string_literal: true

require_relative "hot_reload/remote_file_reloader"

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
          @remote_file_reloader = RemoteFileReloader.new(ctx, theme: @theme, streams: @streams)
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
          files = (modified + added)
            .reject { |file| @ignore_filter&.ignore?(file) }
            .map { |file| @theme[file] }

          files -= liquid_css_files = files.select(&:liquid_css?)

          hot_reload(files) unless files.empty?
          remote_reload(liquid_css_files)
        end

        private

        def hot_reload(files)
          paths = files.map(&:relative_path)
          @streams.broadcast(JSON.generate(modified: paths))
          @ctx.debug("[HotReload] Modified #{paths.join(", ")}")
        end

        def remote_reload(files)
          files.each do |file|
            @remote_file_reloader.reload(file)
          end
        end

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
