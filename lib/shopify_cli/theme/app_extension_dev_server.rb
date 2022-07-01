# frozen_string_literal: true

require_relative "dev_server"
require_relative "dev_server/app_extensions"
require_relative "dev_server/web_server"

require "pathname"

module ShopifyCLI
  module Theme
    module AppExtensionDevServer
      # Errors
      Error = Class.new(StandardError)
      AddressBindingError = Class.new(Error)
      
      class << self
        attr_accessor :ctx

        # def start(ctx, root, host: "127.0.0.1", theme: nil, port: 9292, poll: false)
        def start(ctx)
          # TODO get params from CLI 
          @app = DevServer::AppExtensions.new
          host = "127.0.0.1"
          port = 9292
          logger = WEBrick::Log.new(nil, WEBrick::BasicLog::INFO)

          DevServer::WebServer.run(
            @app,
            BindAddress: host,
            Port: port,
            Logger: logger,
            AccessLog: [],
          )
          # AppExtensionWebServer.run
        end
      end
    end
  end
end

