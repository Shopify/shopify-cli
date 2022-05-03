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

      def test_can_specify_editor_sync
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, ".", host: Theme::Command::Serve::DEFAULT_HTTP_HOST, editor_sync: true)

        run_serve_command do |command|
          command.options.flags[:editor_sync] = true
        end
      end

      def test_can_specify_root
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, "dist", host: Theme::Command::Serve::DEFAULT_HTTP_HOST)

        run_serve_command(["dist"])
      end

      def test_valid_authentication_method_when_storefront_renderer_token_and_password_are_present
        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("password")
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns("SFR token")

        ShopifyCLI::Context.expects(:abort).never

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      def test_valid_authentication_method_when_storefront_renderer_token_is_present_and_password_is_not_present
        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns(nil)
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns("SFR token")

        ShopifyCLI::Context.expects(:abort).never

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      def test_valid_authentication_method_when_storefront_renderer_token_is_not_present_and_password_is_present
        error_message = "error message"
        help_message = "help message"

        ShopifyCLI::Context.stubs(:message)
          .with("theme.serve.auth.error_message", ShopifyCLI::TOOL_NAME)
          .returns(error_message)
        ShopifyCLI::Context.stubs(:message)
          .with("theme.serve.auth.help_message", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
          .returns(help_message)

        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("password")
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns(nil)

        ShopifyCLI::Context.expects(:abort).with(error_message, help_message)

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      def test_valid_authentication_method_when_storefront_renderer_token_and_password_are_not_present
        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns(nil)
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns(nil)

        ShopifyCLI::Context.expects(:abort).never

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      private

      def run_serve_command(argv = [])
        command = Theme::Command::Serve.new(@ctx)

        stubs_auth(command)
        stubs_parser(command, argv)
        yield(command) if block_given?

        command.call(nil, :serve)
      end

      def stubs_parser(command, argv)
        argv = ["shopify", "theme", "serve"] + argv
        parser = command.options.parser
        parser.stubs(:default_argv).returns(argv)
      end

      def stubs_auth(command)
        command.stubs(:valid_authentication_method!)
      end
    end
  end
end
