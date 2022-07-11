# frozen_string_literal: true

require_relative "dev_server"
require_relative "dev_server/app_extensions"
require_relative "dev_server/web_server"

require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/syncer"
require "pathname"

require_relative "development_theme"
require_relative "dev_server/hot_reload"
require_relative "dev_server/reload_mode"
require_relative "dev_server/app_extension_local_assets"
require_relative "dev_server/app_extension_proxy"
require_relative "dev_server/sse"
require_relative "dev_server/cdn_fonts"
require_relative "dev_server/app_extension_watcher"
require_relative "dev_server/web_server"
require_relative "dev_server/certificate_manager"
require_relative "dev_server/header_hash"

module ShopifyCLI
  module Theme
    module DevServer
      module AppExtensionDevServer
        class << self
          attr_accessor :ctx

          def start(ctx, root, host: "127.0.0.1", _theme: nil, port: 9292, poll: false)
            @ctx = ctx
            # @app = AppExtensions.new

            tmp_theme_dir = root + "/../tmp_theme"
            @ctx.mkdir_p(tmp_theme_dir)

            @theme = DevelopmentTheme.find_or_create!(@ctx, root: tmp_theme_dir)
            @extension = AppExtension.new(@ctx, root: root, id: 1234)
            logger = WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
            watcher = AppExtensionWatcher.new(@ctx, extension: @extension, poll: poll)

            @app = AppExtensionProxy.new(@ctx, extension: @extension, theme: @theme)
            @app = AppExtensionLocalAssets.new(@ctx, @app, extension: @extension)
            @app = HotReload.new(@ctx, @app, theme: @theme, watcher: watcher, mode: ReloadMode.default,
              extension: @extension)
            address = "http://#{host}:#{port}"

            trap("INT") do
              stop
            end

            begin
              preview_suffix = ctx.message("theme.serve.download_changes")
              preview_message = ctx.message(
                "theme.serve.customize_or_preview",
                preview_suffix,
                @theme.editor_url,
                @theme.preview_url
              )

              ctx.puts(ctx.message("extension.serve.frame_title", root))
              ctx.open_url!(address)
              ctx.puts(preview_message)
              watcher.start
              WebServer.run(
                @app,
                BindAddress: host,
                Port: port,
                Logger: logger,
                AccessLog: [],
              )
            rescue ShopifyCLI::API::APIRequestNotFoundError
              @ctx.abort(@ctx.message("theme.pull.theme_not_found", "##{theme.id}"))
            ensure
              watcher.stop
              @ctx.rm_rf(tmp_theme_dir)
            end
          end

          def stop
            @ctx.puts("Stopping…")
            WebServer.shutdown
          end

          private

          def logger
            if @ctx.debug?
              WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
            else
              WEBrick::Log.new(nil, WEBrick::BasicLog::FATAL)
            end
          end
        end
      end
    end
  end
end
