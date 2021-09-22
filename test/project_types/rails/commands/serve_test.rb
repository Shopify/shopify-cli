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
    end
  end
end
