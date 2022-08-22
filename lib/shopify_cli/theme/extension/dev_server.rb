# frozen_string_literal: true

require "pathname"

require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/dev_server"
require "shopify_cli/theme/extension/host_theme"
require "shopify_cli/theme/syncer"

require_relative "dev_server/local_assets"
require_relative "dev_server/proxy_param_builder"
require_relative "dev_server/watcher"
require_relative "dev_server/hooks/file_change_hook"
require_relative "dev_server/hot_reload"
require_relative "dev_server/hot_reload/script_injector"
require_relative "syncer"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        # Themes
        Proxy = ShopifyCLI::Theme::DevServer::Proxy
        CdnFonts = ShopifyCLI::Theme::DevServer::CdnFonts

        # Extensions
        ScriptInjector = ShopifyCLI::Theme::Extension::DevServer::HotReload::ScriptInjector

        private

        def middleware_stack
          @app = Proxy.new(ctx, theme, param_builder)
          @app = CdnFonts.new(@app, theme: theme)
          @app = LocalAssets.new(ctx, @app, extension)
          @app = HotReload.new(ctx, @app, broadcast_hooks: broadcast_hooks, watcher: watcher, mode: mode,
            script_injector: script_injector)
        end

        def sync_theme
          # Ensures the host theme exists
          !!theme
        end

        def syncer
          @syncer ||= Syncer.new(ctx, extension: extension)
        end

        def theme
          @theme ||= if theme_identifier
            theme = ShopifyCLI::Theme::Theme.find_by_identifier(ctx, identifier: theme_identifier)
            theme || ctx.abort(not_found_error_message)
          else
            HostTheme.find_or_create!(ctx)
          end
        end

        def extension
          @extension ||= AppExtension.new(ctx, root: root, id: 1234)
        end

        def watcher
          @watcher ||= Watcher.new(ctx, syncer: syncer, extension: extension, poll: poll)
        end

        def param_builder
          @param_builder ||= ProxyParamBuilder
            .new
            .with_extension(extension)
            .with_syncer(syncer)
        end

        def setup_server
          CLI::UI::Frame.open(frame_title, color: :magenta, timing: nil) do
            # TODO: https://github.com/Shopify/shopify-cli/issues/2538
            ctx.open_url!(address)
            ctx.puts(preview_message)
          end

          watcher.start
          syncer.start
        end

        # Hooks

        def broadcast_hooks
          file_handler = Hooks::FileChangeHook.new(ctx, extension: extension)
          [file_handler]
        end

        def script_injector
          ScriptInjector.new(ctx)
        end

        # Messages

        def frame_title
          ctx.message("serve.frame_title", root)
        end
      end
    end
  end
end
