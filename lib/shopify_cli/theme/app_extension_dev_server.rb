# frozen_string_literal: true

require_relative "dev_server_common"
require_relative "dev_server/app_extensions"
require_relative "dev_server/web_server"

require "pathname"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionDevServer < DevServerCommon
        class << self
          def start(ctx, root, host: "127.0.0.1", theme: nil, port: 9292, poll: false)
            @app = AppExtensions.new
            logger = WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)

            WebServer.run(
              @app,
              BindAddress: host,
              Port: port,
              Logger: logger,
              AccessLog: [],
            )
          end
        end
      end
    end
  end
end

