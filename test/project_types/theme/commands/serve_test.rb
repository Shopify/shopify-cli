# frozen_string_literal: true
require "project_types/theme/test_helper"
require "shopify_cli/theme/dev_server/errors"

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        @ctx = ShopifyCLI::Context.new
        @root = ShopifyCLI::ROOT + "/test/fixtures/theme"
      end

      def test_serve_command
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST)

        run_serve_command([@root])
      end

      def test_can_specify_bind_address
        ShopifyCLI::Theme::DevServer.expects(:start).with(@ctx, @root, host: "0.0.0.0")

        run_serve_command([@root]) do |command|
          command.options.flags[:host] = "0.0.0.0"
        end
      end

      def test_can_specify_port
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST, port: 9293)

        run_serve_command([@root]) do |command|
          command.options.flags[:port] = 9293
        end
      end

      def test_with_stable
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST, stable: true)

        run_serve_command([@root]) do |command|
          command.options.flags[:stable] = true
        end
      end

      def test_can_specify_poll
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST, poll: true)

        run_serve_command([@root]) do |command|
          command.options.flags[:poll] = true
        end
      end

      def test_can_specify_editor_sync
        ShopifyCLI::Theme::DevServer.expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST, editor_sync: true)

        run_serve_command([@root]) do |command|
          command.options.flags[:editor_sync] = true
        end
      end

      def test_can_specify_theme
        ShopifyCLI::Theme::DevServer
          .expects(:start)
          .with(@ctx, @root, host: Theme::Command::Serve::DEFAULT_HTTP_HOST, theme: 1234)

        run_serve_command([@root]) do |command|
          command.options.flags[:theme] = 1234
        end
      end

      def test_valid_authentication_method_when_storefront_renderer_from_cli3_in_env_is_present
        ShopifyCLI::Environment.stubs(:storefront_renderer_auth_token).returns("CLI3 SFR Token")
        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("password")
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns(nil)

        ShopifyCLI::Context.expects(:abort).never

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      def test_valid_authentication_method_when_storefront_renderer_token_and_password_are_present
        ShopifyCLI::Environment.stubs(:storefront_renderer_auth_token).returns(nil)
        ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("password")
        ShopifyCLI::DB.stubs(:get).with(:storefront_renderer_production_exchange_token).returns("SFR token")

        ShopifyCLI::Context.expects(:abort).never

        command = Theme::Command::Serve.new(@ctx)
        command.send(:valid_authentication_method!)
      end

      def test_valid_authentication_method_when_storefront_renderer_token_is_present_and_password_is_not_present
        ShopifyCLI::Environment.stubs(:storefront_renderer_auth_token).returns(nil)
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

        ShopifyCLI::Environment.stubs(:storefront_renderer_auth_token).returns(nil)
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
