# frozen_string_literal: true
require_relative "dev_server/config"
require_relative "dev_server/hot_reload"
require_relative "dev_server/ignore_filter"
require_relative "dev_server/header_hash"
require_relative "dev_server/local_assets"
require_relative "dev_server/mime_type"
require_relative "dev_server/proxy"
require_relative "dev_server/sse"
require_relative "dev_server/theme"
require_relative "dev_server/uploader"
require_relative "dev_server/watcher"
require_relative "dev_server/web_server"
require_relative "dev_server/certificate_manager"

require "pathname"

module ShopifyCli
  module Theme
    module DevServer
      class << self
        attr_accessor :ctx

        def start(ctx, root, silent: false, port: 9292, env: "development")
          @ctx = ctx
          config = Config.from_path(root, environment: env)
          theme = Theme.new(ctx, config)
          watcher = Watcher.new(ctx, theme)

          # Setup the middleware stack. Mimics Rack::Builder / config.ru, but in reverse order
          @app = Proxy.new(ctx, theme)
          @app = LocalAssets.new(ctx, @app, theme)
          @app = HotReload.new(ctx, @app, theme, watcher)

          theme.ensure_development_theme_exists!

          ctx.print_task("Syncing theme ##{theme.id} on #{theme.shop} ...") unless silent
          watcher.start

          unless silent
            ctx.puts("")
            ctx.puts("Serving #{theme.root}")
            ctx.puts("")
            ctx.open_url!("http://127.0.0.1:#{port}")
            ctx.puts("")
            ctx.puts("Customize this theme in the Online Store Editor:")
            ctx.puts("{{green:#{theme.editor_url}}}")
            ctx.puts("")
            ctx.puts("(Use Ctrl-C to stop)")
          end

          trap("INT") do
            stop
          end

          logger = if ctx.debug?
            WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
          else
            WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
          end

          WebServer.run(
            @app,
            Port: port,
            Logger: logger,
            AccessLog: [],
          )
          watcher.stop
        end

        def stop
          @app.close
          WebServer.shutdown
        end
      end
    end
  end
end
