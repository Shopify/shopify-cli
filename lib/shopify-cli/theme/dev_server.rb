# frozen_string_literal: true
require_relative "config"
require_relative "development_theme"
require_relative "uploader"

require_relative "dev_server/hot_reload"
require_relative "dev_server/header_hash"
require_relative "dev_server/local_assets"
require_relative "dev_server/proxy"
require_relative "dev_server/sse"
require_relative "dev_server/watcher"
require_relative "dev_server/web_server"
require_relative "dev_server/certificate_manager"

require "pathname"

module ShopifyCli
  module Theme
    module DevServer
      class << self
        attr_accessor :ctx

        def start(ctx, root, port: 9292, env: "development", silent: false)
          @ctx = ctx
          config = Config.from_path(root, environment: env)
          theme = DevelopmentTheme.new(ctx, config)
          @uploader = Uploader.new(ctx, theme)
          watcher = Watcher.new(ctx, theme, @uploader)

          # Setup the middleware stack. Mimics Rack::Builder / config.ru, but in reverse order
          @app = Proxy.new(ctx, theme, @uploader)
          @app = LocalAssets.new(ctx, @app, theme)
          @app = HotReload.new(ctx, @app, theme, watcher)
          stopped = false

          theme.ensure_exists!

          trap("INT") do
            stopped = true
            stop
          end

          CLI::UI::Frame.open(@ctx.message("theme.serve.serve")) do
            ctx.print_task("Syncing theme ##{theme.id} on #{theme.shop}")
            @uploader.start_threads
            if silent
              @uploader.upload_theme!(delay_low_priority_files: true)
            else
              @uploader.upload_theme_with_progress_bar!(delay_low_priority_files: true)
            end

            return if stopped

            ctx.puts("")
            ctx.puts("Serving #{theme.root}")
            ctx.puts("")
            ctx.open_url!("http://127.0.0.1:#{port}")
            ctx.puts("")
            ctx.puts("Customize this theme in the Online Store Editor:")
            ctx.puts("{{green:#{theme.editor_url}}}")
            ctx.puts("")
            ctx.puts("Share this theme preview:")
            ctx.puts("{{green:#{theme.preview_url}}}")
            ctx.puts("")
            ctx.puts("(Use Ctrl-C to stop)")
          end

          logger = if ctx.debug?
            WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
          else
            WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
          end

          watcher.start
          WebServer.run(
            @app,
            Port: port,
            Logger: logger,
            AccessLog: [],
          )
          watcher.stop

        rescue ShopifyCli::API::APIRequestForbiddenError,
               ShopifyCli::API::APIRequestUnauthorizedError
          @ctx.abort("You are not authorized to edit themes on #{theme.shop}.\n" \
                     "Make sure you are a user of that store, and allowed to edit themes.")
        end

        def stop
          @ctx.puts("Stopping ...")
          @app.close
          @uploader.shutdown
          WebServer.shutdown
        end
      end
    end
  end
end
