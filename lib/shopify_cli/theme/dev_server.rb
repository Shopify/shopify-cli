# frozen_string_literal: true
require_relative "development_theme"
require_relative "ignore_filter"
require_relative "syncer"

require_relative "dev_server/hot_reload"
require_relative "dev_server/header_hash"
require_relative "dev_server/local_assets"
require_relative "dev_server/proxy"
require_relative "dev_server/sse"
require_relative "dev_server/watcher"
require_relative "dev_server/web_server"
require_relative "dev_server/certificate_manager"

require "pathname"

module ShopifyCLI
  module Theme
    module DevServer
      class << self
        attr_accessor :ctx

        def start(ctx, root, port: 9292, poll: false)
          @ctx = ctx
          theme = DevelopmentTheme.new(ctx, root: root)
          ignore_filter = IgnoreFilter.from_path(root)
          @syncer = Syncer.new(ctx, theme: theme, ignore_filter: ignore_filter)
          watcher = Watcher.new(ctx, theme: theme, syncer: @syncer, ignore_filter: ignore_filter, poll: poll)

          # Setup the middleware stack. Mimics Rack::Builder / config.ru, but in reverse order
          @app = Proxy.new(ctx, theme: theme, syncer: @syncer)
          @app = LocalAssets.new(ctx, @app, theme: theme)
          @app = HotReload.new(ctx, @app, theme: theme, watcher: watcher, ignore_filter: ignore_filter)
          stopped = false

          theme.ensure_exists!

          trap("INT") do
            stopped = true
            stop
          end

          CLI::UI::Frame.open(@ctx.message("theme.serve.serve")) do
            ctx.print_task("Syncing theme ##{theme.id} on #{theme.shop}")
            @syncer.start_threads
            if block_given?
              yield @syncer
            else
              @syncer.upload_theme!(delay_low_priority_files: true)
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

        rescue ShopifyCLI::API::APIRequestForbiddenError,
               ShopifyCLI::API::APIRequestUnauthorizedError
          @ctx.abort("You are not authorized to edit themes on #{theme.shop}.\n" \
                     "Make sure you are a user of that store, and allowed to edit themes.")
        end

        def stop
          @ctx.puts("Stopping…")
          @app.close
          @syncer.shutdown
          WebServer.shutdown
        end
      end
    end
  end
end
