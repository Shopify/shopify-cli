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

        attr_accessor :project, :specification_handler

        class << self
          def start(ctx, root, port: 8282, theme: nil, project:, specification_handler:)
            instance.project = project
            instance.specification_handler = specification_handler

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

          # Ensure the theme app extension is pushed (Spinner required as it might take 1..4 seconds)
          CLI::UI::Spinner.spin(pushing_extension) { |_s| extension }
          clean_last_line
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
            theme = ShopifyCLI::Theme::Theme.find_by_identifier(ctx, identifier: theme_identifier)
            theme || ctx.abort(not_found_error_message)
          else
            HostTheme.find_or_create!(ctx)
          end
        end

        def extension
          return @extension if @extension

          properties = push_theme_app_extension.dig(*%w(data extensionUpdateDraft extensionVersion)) || {}

          @extension = AppExtension.new(
            ctx,
            root: root,
            location: properties["location"],
            registration_id: properties["registrationId"],
          )
        end

        def push_theme_app_extension
          input = {
            api_key: project.app.api_key,
            registration_id: project.registration_id,
            config: JSON.generate(specification_handler.config(ctx)),
            extension_context: specification_handler.extension_context(ctx),
          }

          ShopifyCLI::PartnersAPI.query(ctx, "extension_update_draft", **input)
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

        def clean_last_line
          # move the cursor to the start of the line
          command = "\r"

          # move the cursor up one line
          command += CLI::UI::ANSI.control("A", "")

          # clear the line
          command += CLI::UI::ANSI.control("K", "")

          print(command)
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

        def pushing_extension
          ctx.message("serve.pushing_extension")
        end

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
