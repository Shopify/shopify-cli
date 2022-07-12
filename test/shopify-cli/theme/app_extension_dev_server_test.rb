# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/app_extension_dev_server"

module ShopifyCLI
  module Theme
    class AppExtensionDevServerTest < Minitest::Test
      def setup
        super
        @ctx = ShopifyCLI::Context.new
        @theme = stub(
          "Host Theme Testing",
          root: ".",
          id: 1234,
          name: "HostTheme Test",
          shop: "test.myshopify.io",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          live?: false,
        )
        @extension = stub(
          "Theme App Extension",
          root: ".",
          id: 1234,
          name: "Theme App Extension",
        )
        ShopifyCLI::Theme::DevServer::AppExtensionDevServer.ctx = @ctx
      end

      def test_start_calls_run_webserver
        skip # TODO: once HostTheme abstraction is created modify tests
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

        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(@ctx, root: @theme.root + "/../tmp_theme", identifier: @theme.name)
          .returns(@theme)

        simulate_start_server
      end

      def test_stop_calls_shutdown_webserver
        skip # TODO: once HostTheme abstraction is created modify tests
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
