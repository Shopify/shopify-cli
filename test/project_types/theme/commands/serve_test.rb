# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify_cli/theme/dev_server"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        @ctx = ShopifyCLI::Context.new
      end

      def test_serve_command
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(@ctx, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)

        run_serve_command
      end

      def test_serve_command_raises_abort_when_cant_bind_address
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(@ctx, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)
          .raises(ShopifyCLI::Theme::DevServer::AddressBindingError)

        assert_raises ShopifyCLI::Abort do
          run_serve_command
        end
      end

      def test_can_specify_bind_address
        ShopifyCLI::Theme::DevServer.expects(:start).with(@ctx, ".", host: "0.0.0.0")

        run_serve_command do |command|
          command.options.flags[:host] = "0.0.0.0"
        end
      end

      def test_can_specify_port
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST, port: 9293)

        run_serve_command do |command|
          command.options.flags[:port] = 9293
        end
      end

      def test_can_specify_poll
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST, poll: true)

        run_serve_command do |command|
          command.options.flags[:poll] = true
        end
      end

      def test_can_specify_root
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, "dist", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)

        run_serve_command(["dist"])
      end

      private

      def run_serve_command(args = [])
        command = Theme::Command::Serve.new(@ctx)
        yield(command) if block_given?
        command.call(args, :serve)
      end
    end
  end
end
