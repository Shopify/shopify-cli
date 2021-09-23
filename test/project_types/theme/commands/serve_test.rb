# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify_cli/theme/dev_server"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_serve_command
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".", optionally({}))

        Theme::Command::Serve.new(context).call
      end

      def test_can_specify_port
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".", port: 9293)

        command = Theme::Command::Serve.new(context)
        command.options.flags[:port] = 9293
        command.call
      end

      def test_can_specify_env
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".", env: "staging")

        command = Theme::Command::Serve.new(context)
        command.options.flags[:env] = "staging"
        command.call
      end
    end
  end
end
