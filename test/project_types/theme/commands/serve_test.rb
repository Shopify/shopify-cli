# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify-cli/theme/dev_server"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_serve_command
        context = ShopifyCli::Context.new
        ShopifyCli::Theme::DevServer.expects(:start).with(".", optionally({}))

        Theme::Commands::Serve.new(context).call
      end

      def test_can_specify_port
        context = ShopifyCli::Context.new
        ShopifyCli::Theme::DevServer.expects(:start).with(".", port: 9293)

        command = Theme::Commands::Serve.new(context)
        command.options.flags[:port] = 9293
        command.call
      end

      def test_can_specify_debug
        context = ShopifyCli::Context.new
        ShopifyCli::Theme::DevServer.expects(:debug=).with(true)
        ShopifyCli::Theme::DevServer.expects(:start)

        command = Theme::Commands::Serve.new(context)
        command.options.flags[:debug] = true
        command.call
      end
    end
  end
end
