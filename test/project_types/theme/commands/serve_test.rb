# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify-cli/theme/dev_server"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_serve_command
        context = ShopifyCli::Context.new
        ShopifyCli::Theme::DevServer.expects(:start).with(".")

        Theme::Commands::Serve.new(context).call
      end

      def test_can_specify_port
        context = ShopifyCli::Context.new
        ShopifyCli::Theme::DevServer.expects(:start).with(".", port: 9293)

        command = Theme::Commands::Serve.new(context)
        command.options.flags[:port] = 9293
        command.call
      end
    end
  end
end
