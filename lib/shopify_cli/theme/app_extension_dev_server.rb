# frozen_string_literal: true

require_relative "dev_server"
require_relative "dev_server/app_extensions"
require_relative "dev_server/web_server"

require "pathname"

module ShopifyCLI
  module Theme
    module DevServer
      module AppExtensionDevServer
        class << self
          attr_accessor :ctx

          def start(ctx, _root, host: "127.0.0.1", _theme: nil, port: 9292, _poll: false)
            @ctx = ctx
            @app = AppExtensions.new

            trap("INT") do
              stop
            end

            WebServer.run(
              @app,
              BindAddress: host,
              Port: port,
              Logger: logger,
              AccessLog: [],
            )
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
