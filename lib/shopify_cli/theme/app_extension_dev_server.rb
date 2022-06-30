# frozen_string_literal: true

require_relative "dev_server/app_extensions"

require "pathname"

module ShopifyCLI
  module Theme
    module AppExtensionDevServer
      # Errors
      Error = Class.new(StandardError)
      AddressBindingError = Class.new(Error)

      # move logic from web server to lib/shopify_cli/thread_pool.rb
      class AppExtensionWebServer < WEBrick::HTTPServlet::AbstractServlet
        def self.run
          options = {
            :BindAddress=>"127.0.0.1", 
            :Port=>9292
          }
          @server = ::WEBrick::HTTPServer.new(options)
          @server.mount '/', AppExtensionWebServer
          @server.start
        end

        def do_GET request, response
          # status, content_type, body = do_stuff_with request

          response.status = 200
          response['Content-Type'] = 'text/plain'
          response.body = 'Hello, World!'
        end
      end

      class << self
        attr_accessor :ctx

        # def start(ctx, root, host: "127.0.0.1", theme: nil, port: 9292, poll: false)
        def start(ctx)

          # WebServer.run(
          #   @app,
          #   BindAddress: host,
          #   Port: port,
          #   Logger: logger,
          #   AccessLog: [],
          # )
          # remote_watcher.stop if editor_sync
          # watcher.stop
          AppExtensionWebServer.run
        end
      end
    end
  end
end

