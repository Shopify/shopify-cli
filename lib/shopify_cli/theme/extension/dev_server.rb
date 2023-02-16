# frozen_string_literal: true

require "pathname"

require "shopify_cli/theme/extension/app_extension"
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

        attr_accessor :project, :specification_handler, :generate_tmp_theme

        class << self
          def start(ctx, root, port: 9292, theme: nil, generate_tmp_theme: false, project:, specification_handler:)
            instance.project = project
            instance.specification_handler = specification_handler
            instance.generate_tmp_theme = generate_tmp_theme

            super(ctx, root, port: port, theme: theme)
          end
        end

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
          theme

          # Ensure the theme app extension is pushed
          extension
        end

        def syncer
          @syncer ||= Syncer.new(
            ctx,
            extension: extension,
            project: project,
            specification_handler: specification_handler
          )
        end

        def theme
          @theme ||= if theme_identifier
            theme = HostTheme.find_by_identifier(ctx, identifier: theme_identifier)
            ctx.abort(not_found_error_message) unless theme
            theme.generate_tmp_theme if generate_tmp_theme
            theme
          else
            HostTheme.find_or_create!(ctx)
          end
        end

        def extension
          return @extension if @extension

          app = fetch_theme_app_extension_info.dig(*%w(data app)) || {}

          app_id = app["id"]

          registrations = app["extensionRegistrations"] || []
          registration = registrations.find { |r| r["type"] == "THEME_APP_EXTENSION" } || {}

          location = registration.dig(*%w(draftVersion location))
          registration_id = registration["id"]

          @extension = AppExtension.new(
            ctx,
            root: root,
            app_id: app_id,
            location: location,
            registration_id: registration_id,
          )
        end

        def fetch_theme_app_extension_info
          params = {
            api_key: project.app.api_key,
            type: specification_handler.identifier.downcase,
          }

          PartnersAPI.query(@ctx, "get_extension_registrations", **params)
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
            ctx.puts(preview_message)
          end

          watcher.start
          syncer.start
        end

        # Hooks

        def broadcast_hooks
          file_handler = Hooks::FileChangeHook.new(ctx, extension: extension, syncer: syncer)
          [file_handler]
        end

        def script_injector
          ScriptInjector.new(ctx)
        end

        # Messages

        def frame_title
          ctx.message("serve.frame_title", root)
        end

        def preview_message
          ctx.message("serve.preview_message", extension.location, theme.editor_url, address)
        end
      end
    end
  end
end
