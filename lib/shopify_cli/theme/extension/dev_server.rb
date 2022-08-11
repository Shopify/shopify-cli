# frozen_string_literal: true

require "pathname"

require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/dev_server"
require "shopify_cli/theme/extension/host_theme"
require "shopify_cli/theme/syncer"

require_relative "dev_server/app_extensions"
require_relative "dev_server/local_assets"
require_relative "dev_server/proxy_param_builder"
require_relative "dev_server/watcher"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        Proxy = ShopifyCLI::Theme::DevServer::Proxy
        HotReload = ShopifyCLI::Theme::DevServer::HotReload

        private

        def middleware_stack
          @app = Proxy.new(ctx, theme, param_builder)
          @app = LocalAssets.new(ctx, app, extension)
          @app = HotReload.new(ctx, app, theme: theme, watcher: watcher, mode: mode, extension: extension)
        end

        def sync_theme
          # Ensures the hot theme exists
          !!theme
        end

        def syncer
          # TODO: Instantiate 'Sycner' here
          todo = Object.new

          def todo.shutdown
            puts "TODO: Call 'shutdown' method on syncer"
          end

          todo
        end

        def theme
          @theme ||= if identifier
            theme = ShopifyCLI::Theme::Theme.find_by_identifier(ctx, root: root, identifier: identifier)
            theme || ctx.abort(not_found_error_message)
          else
            HostTheme.find_or_create!(ctx)
          end
        end

        def extension
          @extension ||= AppExtension.new(ctx, root: root, id: 1234)
        end

        def watcher
          @watcher ||= Watcher.new(ctx, extension: extension, poll: poll)
        end

        def param_builder
          @param_builder ||= ProxyParamBuilder.new
            .new
            .with_extension(extension)
        end

        def setup_server
          ctx.puts(frame_title)
          ctx.open_url!(address)
          ctx.puts(preview_message)

          watcher.start
        end

        def teardown_server
          watcher.stop
        end

        # Messages

        def frame_title
          ctx.message("extension.serve.frame_title", root)
        end
      end
    end
  end
end
