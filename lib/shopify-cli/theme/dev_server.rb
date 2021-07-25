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

module ShopifyCli
  module Theme
    module DevServer
      class << self
        attr_accessor :ctx

        def start(ctx, working_dir: ".", host: "localhost", port: 9292, use_tls: true)
          @ctx = ctx
          theme = DevelopmentTheme.new(ctx, working_dir: working_dir)
          ignore_filter = IgnoreFilter.from_path(working_dir)
          @syncer = Syncer.new(ctx, theme: theme, ignore_filter: ignore_filter)
          watcher = Watcher.new(ctx, theme: theme, syncer: @syncer, ignore_filter: ignore_filter)

          # Setup the middleware stack. Mimics Rack::Builder / config.ru, but in reverse order
          @app = Proxy.new(ctx, theme: theme, syncer: @syncer, host: host, port: port)
          @app = LocalAssets.new(ctx, @app, theme: theme)
          @app = HotReload.new(ctx, @app, theme: theme, watcher: watcher, ignore_filter: ignore_filter)
          stopped = false

          theme.ensure_exists!

          trap("INT") do
            stopped = true
            stop
          end

          protocol = use_tls ? "https" : "http"
          CLI::UI::Frame.open(@ctx.message("theme.serve.serve")) do
            ctx.print_task("Syncing theme ##{theme.id} on #{theme.shop}")
            @syncer.start_threads
            if block_given?
              yield @syncer
            else
              @syncer.upload_theme!(delay_low_priority_files: true)
            end

            return if stopped

            ctx.print_task("Retrieving TLS certificate for {{green:#{host}}}")
            ctx.print_task("Serving from {{green:#{theme.working_dir}}}")
            ctx.puts("")
            ctx.open_url!("#{protocol}://#{host}:#{port}")
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

          options = {
            Port: port,
            Logger: logger,
            AccessLog: [],
            SSLEnable: use_tls,
            StartCallback: -> { @ctx.open_browser_url!("#{protocol}://#{host}:#{port}") },
          }

          if use_tls
            manager = CertificateManager.new(ctx)
            certificate_file = manager.find_or_create_certificate!(host)
            private_key_file = manager.private_key
            intermediate_file = manager.intermediate_certificate
            options[:SSLCertificate] = certificate_file
            options[:SSLPrivateKey] = private_key_file
            # WEBrick doesn't automatically extract the intermediate from the certificate so we must specify it ourselves
            # This is more of an issue for Let's Encrypt TLS certificates (vs. self signed where the CA is the cert)
            options[:SSLExtraChainCert] = intermediate_file if intermediate_file
          end

          watcher.start
          WebServer.run(@app, **options)
          watcher.stop

        rescue ShopifyCli::API::APIRequestForbiddenError,
               ShopifyCli::API::APIRequestUnauthorizedError
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
