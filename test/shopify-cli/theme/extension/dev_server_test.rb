# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/extension/dev_server"

module ShopifyCLI
  module Theme
    module Extension
      class DevServerTest < Minitest::Test
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
          ShopifyCLI::Theme::Extension::DevServer.ctx = @ctx
        end

        # TODO: once CLI args are created we can test functionality similar to theme/dev_server_test.rb

        private

        def simulate_start_server(root = ".")
          ShopifyCLI::Theme::Extension::DevServer
            .send(:start, @ctx, root)
        end

        def simulate_stop_server
          ShopifyCLI::Theme::Extension::DevServer
            .send(:stop)
        end
      end
    end
  end
end
