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
      # Errors
      Error = Class.new(StandardError)
      AddressBindingError = Class.new(Error)

      class << self
        attr_accessor :ctx

        def start(ctx, root, http_bind: "127.0.0.1", port: 9292, poll: false)
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
          address = "http://#{http_bind}:#{port}"

          theme.ensure_exists!

          trap("INT") do
            stopped = true
            stop
          end

          CLI::UI::Frame.open(@ctx.message("theme.serve.viewing_theme")) do
            ctx.print_task(ctx.message("theme.serve.syncing_theme", theme.id, theme.shop))
            @syncer.start_threads
            if block_given?
              yield @syncer
            else
              @syncer.upload_theme!(delay_low_priority_files: true)
            end

            return if stopped

            ctx.puts(ctx.message("theme.serve.serving", theme.root))
            ctx.open_url!(address)
            ctx.puts(ctx.message("theme.serve.customize_or_preview", theme.editor_url, theme.preview_url))
          end

          logger = if ctx.debug?
            WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
          else
            WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
          end

          watcher.start
          WebServer.run(
            @app,
            BindAddress: http_bind,
            Port: port,
            Logger: logger,
            AccessLog: [],
          )
          watcher.stop

        rescue ShopifyCLI::API::APIRequestForbiddenError,
               ShopifyCLI::API::APIRequestUnauthorizedError
          raise ShopifyCLI::Abort, @ctx.message("theme.serve.ensure_user", theme.shop)
        rescue Errno::EADDRINUSE
          abort_address_already_in_use(address)
        rescue Errno::EADDRNOTAVAIL
          raise AddressBindingError, "Error binding to the address #{http_bind}."
        end

        def stop
          @ctx.puts("Stopping…")
          @app.close
          @syncer.shutdown
          WebServer.shutdown
        end

        private

        def abort_address_already_in_use(address)
          open_frame(@ctx.message("theme.serve.already_in_use_error"), color: :red) do
            @ctx.puts(@ctx.message("theme.serve.address_already_in_use", address))
          end

          open_frame(@ctx.message("theme.serve.try_this"), color: :green) do
            @ctx.puts(@ctx.message("theme.serve.try_port_option"))
          end

          raise ShopifyCLI::AbortSilent
        end

        def open_frame(title, color:, &block)
          CLI::UI::Frame.open(title, color: CLI::UI.resolve_color(color), timing: false, &block)
        end
      end
    end
  end
end
