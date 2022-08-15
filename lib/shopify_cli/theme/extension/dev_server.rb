# frozen_string_literal: true

require "pathname"

require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/dev_server"
require "shopify_cli/theme/extension/host_theme"
require "shopify_cli/theme/syncer"

require_relative "dev_server/local_assets"
require_relative "dev_server/proxy_param_builder"
require_relative "dev_server/watcher"

require_relative "syncer"

module ShopifyCLI
  module Theme
    module Extension
      module DevServer
        class << self
          attr_accessor :ctx

          Proxy = ShopifyCLI::Theme::DevServer::Proxy
          HotReload = ShopifyCLI::Theme::DevServer::HotReload
          ReloadMode = ShopifyCLI::Theme::DevServer::ReloadMode
          WebServer = ShopifyCLI::Theme::DevServer::WebServer

          def start(ctx, root, host: "127.0.0.1", _theme: nil, port: 9292, poll: false)
            @ctx = ctx

            @theme = HostTheme.find_or_create!(@ctx)
            @extension = AppExtension.new(@ctx, root: root, id: 1234)
            @syncer = Syncer.new(@ctx, extension: @extension)
            logger = WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)
            watcher = Watcher.new(@ctx, syncer: @syncer, extension: @extension, poll: poll)
            param_builder = ProxyParamBuilder.new.with_extension(@extension).with_syncer(@syncer)

            @app = Proxy.new(@ctx, @theme, param_builder)
            @app = LocalAssets.new(@ctx, @app, @extension)
            @app = HotReload.new(@ctx, @app, theme: @theme, watcher: watcher,
              mode: ReloadMode.default,
              extension: @extension)
            address = "http://#{host}:#{port}"

            trap("INT") do
              stop
            end

            begin
              @syncer.start
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
              watcher.stop
            rescue ShopifyCLI::API::APIRequestNotFoundError
              @ctx.abort(@ctx.message("theme.pull.theme_not_found", "##{theme.id}"))
            end
          end

          def stop
            @ctx.puts("Stopping…")
            @app.close
            @syncer.shutdown
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
