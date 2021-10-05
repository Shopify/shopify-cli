# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context("app_types", "rails")
        ShopifyCLI::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
        @context.stubs(:system)
      end

      def test_server_command
        ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
        @context.stubs(:getenv).with("GEM_HOME").returns("/gem/path")
        @context.stubs(:getenv).with("GEM_PATH").returns("/gem/path")
        @context.expects(:system).with(
          "bin/rails server",
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            "PORT" => "8081",
            "GEM_PATH" => "/gem/path",
          }
        )
        Rails::Command::Serve.new(@context).call
      end

      def test_server_command_with_invalid_host_url
        ShopifyCLI::Tunnel.stubs(:start).returns("garbage://example.com")
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call).never
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).never
        @context.expects(:system).with(
          "bin/rails server",
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            "PORT" => "8081",
          }
        ).never

        assert_raises ShopifyCLI::Abort do
          Rails::Command::Serve.new(@context).call
        end
      end

      def test_open_while_run
        ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, "https://example.com"
        )
        @context.expects(:puts).with(
          "\n" +
          @context.message("rails.serve.open_info", "https://example.com/login?shop=my-test-shop.myshopify.com") +
          "\n"
        )
        Rails::Command::Serve.new(@context).call
      end

      def test_update_env_with_host
        ShopifyCLI::Tunnel.expects(:start).never
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, "https://example-foo.com"
        )
        command = Rails::Command::Serve.new(@context)
        command.options.flags[:host] = "https://example-foo.com"
        command.call
      end

      def test_server_command_when_port_passed
        ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
        @context.stubs(:getenv).with("GEM_HOME").returns("/gem/path")
        @context.stubs(:getenv).with("GEM_PATH").returns("/gem/path")
        @context.expects(:system).with(
          "bin/rails server",
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            "PORT" => "5000",
            "GEM_PATH" => "/gem/path",
          }
        )
        command = Rails::Command::Serve.new(@context)
        command.options.flags[:port] = "5000"
        command.call
      end

      def test_server_command_when_invalid_port_passed
        invalid_port = "NOT_PORT"
        ShopifyCLI::Tunnel.stubs(:start).returns("https://example.com")
        ShopifyCLI::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCLI::Resources::EnvFile.any_instance.expects(:update)
        @context.stubs(:getenv).with("GEM_HOME").returns("/gem/path")
        @context.stubs(:getenv).with("GEM_PATH").returns("/gem/path")
        @context.expects(:abort).with(
          @context.message("core.app.serve.error.invalid_port", invalid_port)
        )
        # command = Rails::Command::Serve.new(@context)
        # command.options.flags[:port] = invalid_port
        # command.call
        run_cmd("app rails serve --port=#{invalid_port}")
      end
    end
  end
end
