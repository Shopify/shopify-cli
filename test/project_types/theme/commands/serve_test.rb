# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify_cli/theme/dev_server"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_serve_command
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(context, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)

        Theme::Command::Serve.new(context).call
      end

      def test_serve_command_raises_abort_when_cant_bind_address
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(context, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)
          .raises(ShopifyCLI::Theme::DevServer::AddressBindingError)

        assert_raises ShopifyCLI::Abort do
          Theme::Command::Serve.new(context).call
        end
      end

      def test_can_specify_bind_address
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".", host: "0.0.0.0")

        command = Theme::Command::Serve.new(context)
        command.options.flags[:host] = "0.0.0.0"
        command.call
      end

      def test_can_specify_port
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".",
          host: Theme::Command::Serve::DEFAULT_HTTP_HOST, port: 9293)

        command = Theme::Command::Serve.new(context)
        command.options.flags[:port] = 9293
        command.call
      end

      def test_can_specify_poll
        context = ShopifyCLI::Context.new
        ShopifyCLI::Theme::DevServer.expects(:start).with(context, ".",
          host: Theme::Command::Serve::DEFAULT_HTTP_HOST, poll: true)

        command = Theme::Command::Serve.new(context)
        command.options.flags[:poll] = true
        command.call
      end
    end
  end
end
