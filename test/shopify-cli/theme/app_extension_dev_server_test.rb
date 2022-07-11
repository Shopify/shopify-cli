# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/app_extension_dev_server"

module ShopifyCLI
  module Theme
    class AppExtensionDevServerTest < Minitest::Test
      def setup
        super
        @ctx = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer::AppExtensionDevServer.ctx = @ctx
      end

      def test_start_calls_run_webserver
        logger = mock("Logger")
        app = mock("App")

        ShopifyCLI::Theme::DevServer::AppExtensions
          .expects(:new)
          .returns(app)
        ShopifyCLI::Theme::DevServer::AppExtensionDevServer
          .stubs(:logger)
          .returns(logger)

        ShopifyCLI::Theme::DevServer::WebServer
          .expects(:run)
          .with(app, BindAddress: "127.0.0.1", Port: 9292, Logger: logger, AccessLog: [])
          .returns(nil)

        simulate_start_server
      end

      def test_stop_calls_shutdown_webserver
        ShopifyCLI::Theme::DevServer::WebServer
          .expects(:shutdown)
          .returns(nil)

        simulate_stop_server
      end

      private

      def simulate_start_server(root = ".")
        ShopifyCLI::Theme::DevServer::AppExtensionDevServer
          .send(:start, @ctx, root)
      end

      def simulate_stop_server
        ShopifyCLI::Theme::DevServer::AppExtensionDevServer
          .send(:stop)
      end
    end
  end
end
