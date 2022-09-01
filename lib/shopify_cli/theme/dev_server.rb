# frozen_string_literal: true

require "pathname"
require "singleton"

require_relative "dev_server/cdn_fonts"
require_relative "dev_server/certificate_manager"
require_relative "dev_server/errors"
require_relative "dev_server/header_hash"
require_relative "dev_server/hot_reload"
require_relative "dev_server/hot_reload/script_injector"
require_relative "dev_server/local_assets"
require_relative "dev_server/proxy_param_builder"
require_relative "dev_server/proxy"
require_relative "dev_server/reload_mode"
require_relative "dev_server/remote_watcher"
require_relative "dev_server/sse"
require_relative "dev_server/watcher"
require_relative "dev_server/web_server"
require_relative "dev_server/hooks/file_change_hook"

require_relative "development_theme"
require_relative "ignore_filter"
require_relative "syncer"

module ShopifyCLI
  module Theme
    class DevServer
      include Singleton

      attr_reader :app, :stopped, :ctx, :root, :host, :theme_identifier, :port, :poll, :editor_sync, :stable, :mode,
        :block, :include_filter, :ignore_filter

      class << self
        def start(
          ctx,
          root,
          host: "127.0.0.1",
          theme: nil,
          port: 9292,
          poll: false,
          editor_sync: false,
          stable: false,
          mode: ReloadMode.default,
          includes: nil,
          ignores: nil,
          &block
        )
          instance.setup(
            ctx,
            root,
            host,
            theme,
            port,
            poll,
            editor_sync,
            stable,
            mode,
            includes,
            ignores,
            &block
          )
          instance.start
        end

        def stop
          instance.stop
        end
      end

      # rubocop:disable Metrics/ParameterLists
      def setup(
        ctx,
        root,
        host,
        theme_identifier,
        port,
        poll,
        editor_sync,
        stable,
        mode,
        includes,
        ignores,
        &block
      )
        @ctx = ctx
        @root = root
        @host = host
        @theme_identifier = theme_identifier
        @port = port
        @poll = poll
        @editor_sync = editor_sync
        @stable = stable
        @mode = mode
        @block = block

        @include_filter = ShopifyCLI::Theme::IncludeFilter.new(root, includes)
        @ignore_filter = ShopifyCLI::Theme::IgnoreFilter.from_path(root)
        @ignore_filter.add_patterns(ignores) if ignores
      end

      def start
        sync_theme

        # Handle process stop
        trap("INT") { stop }

        # Setup the middleware stack. Mimics Rack::Builder / config.ru, but in reverse order
        @app = middleware_stack

        # Start development server
        setup_server
        start_server
        teardown_server

      rescue ShopifyCLI::API::APIRequestForbiddenError,
             ShopifyCLI::API::APIRequestUnauthorizedError
        ctx.abort(ensure_user_message)
      rescue Errno::EADDRINUSE
        ctx.abort(port_error_message, port_error_help_message)
      rescue Errno::EADDRNOTAVAIL
        ctx.abort(binding_error_message)
      end

      def stop
        @stopped = true

        ctx.puts(stopping_message)
        app.close
        WebServer.shutdown
      end

      private

      def setup_server
        watcher.start
        remote_watcher.start if editor_sync
      end

      def teardown_server
        # Use instance variables, so we don't build components
        # at the teardown phase.
        @remote_watcher&.stop if editor_sync
        @watcher&.stop
        @syncer&.shutdown
      end

      def start_server
        WebServer.run(
          app,
          BindAddress: host,
          Port: port,
          Logger: logger,
          AccessLog: [],
        )
      end

      def middleware_stack
        @app = Proxy.new(ctx, theme, param_builder)
        @app = CdnFonts.new(@app, theme: theme)
        @app = LocalAssets.new(ctx, @app, theme)
        @app = HotReload.new(ctx, @app, broadcast_hooks: broadcast_hooks, watcher: watcher, mode: mode,
          script_injector: script_injector)
      end

      def sync_theme
        CLI::UI::Frame.open(viewing_theme_message) do
          ctx.print_task(syncing_theme_message)
          syncer.start_threads

          if block
            block.call(syncer)
          else
            syncer.upload_theme!(delay_low_priority_files: true)
          end

          return if stopped

          ctx.puts(serving_theme_message)
          ctx.open_url!(address)
          ctx.open_browser_url!(address)
          ctx.puts(preview_message)
        end
      end

      def theme
        @theme ||= if theme_identifier
          theme = ShopifyCLI::Theme::Theme.find_by_identifier(ctx, root: root, identifier: theme_identifier)
          theme || ctx.abort(not_found_error_message)
        else
          DevelopmentTheme.find_or_create!(ctx, root: root)
        end
      end

      def syncer
        @syncer ||= Syncer.new(
          ctx,
          theme: theme,
          include_filter: include_filter,
          ignore_filter: ignore_filter,
          overwrite_json: !editor_sync,
          stable: stable
        )
      end

      def watcher
        @watcher ||= Watcher.new(
          ctx,
          theme: theme,
          ignore_filter: ignore_filter,
          syncer: syncer,
          poll: poll
        )
      end

      def remote_watcher
        @remote_watcher ||= RemoteWatcher.to(
          theme: theme,
          syncer: syncer
        )
      end

      def param_builder
        @param_builder ||= ProxyParamBuilder
          .new
          .with_theme(theme)
          .with_syncer(syncer)
      end

      def logger
        @logger ||= if ctx.debug?
          WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
        else
          WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
        end
      end

      # Hooks

      def broadcast_hooks
        file_handler = Hooks::FileChangeHook.new(ctx, theme: theme, include_filter: include_filter,
          ignore_filter: ignore_filter)
        [file_handler]
      end

      def script_injector
        HotReload::ScriptInjector.new(ctx, theme: theme)
      end

      def address
        @address ||= "http://#{host}:#{port}"
      end

      # Messages

      def ensure_user_message
        shop = ShopifyCLI::AdminAPI.get_shop_or_abort(ctx)
        ctx.message("theme.serve.ensure_user", shop)
      end

      def port_error_message
        ctx.message("theme.serve.address_already_in_use", address)
      end

      def port_error_help_message
        ctx.message("theme.serve.try_port_option")
      end

      def binding_error_message
        ctx.message("theme.serve.binding_error", ShopifyCLI::TOOL_NAME)
      end

      def viewing_theme_message
        ctx.message("theme.serve.viewing_theme")
      end

      def syncing_theme_message
        ctx.message("theme.serve.syncing_theme", theme.id, theme.shop)
      end

      def serving_theme_message
        ctx.message("theme.serve.serving", theme.root)
      end

      def stopping_message
        ctx.message("theme.serve.stopping")
      end

      def not_found_error_message
        ctx.message("theme.serve.theme_not_found", theme_identifier)
      end

      def preview_message
        preview_suffix = editor_sync ? "" : ctx.message("theme.serve.download_changes")

        ctx.message(
          "theme.serve.customize_or_preview",
          preview_suffix,
          theme.editor_url,
          theme.preview_url
        )
      end
    end
  end
end
