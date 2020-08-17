# frozen_string_literal: true
require 'project_types/rails/test_helper'

module Rails
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context('app_types', 'rails')
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        @context.stubs(:system)
      end

      def test_server_command
        ShopifyCli::Tunnel.stubs(:start).returns('https://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update)
        @context.stubs(:getenv).with('GEM_HOME').returns('/gem/path')
        @context.stubs(:getenv).with('GEM_PATH').returns('/gem/path')
        @context.expects(:system).with(
          'bin/rails server',
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            'PORT' => '8081',
            'GEM_PATH' => '/gem/path',
          }
        )
        Rails::Commands::Serve.new(@context).call
      end

      def test_server_command_with_invalid_host_url
        ShopifyCli::Tunnel.stubs(:start).returns('garbage://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call).never
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).never
        @context.expects(:system).with(
          'bin/rails server',
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            'PORT' => '8081',
          }
        ).never

        assert_raises ShopifyCli::Abort do
          Rails::Commands::Serve.new(@context).call
        end
      end

      def test_open_while_run
        ShopifyCli::Context.any_instance.stubs(:on_siginfo).yields
        ShopifyCli::Tunnel.stubs(:start).returns('https://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example.com'
        )
        ShopifyCli::Context.any_instance.stubs(:mac?).returns(true)
        ShopifyCli::Context.any_instance.expects(:open_url!).with(
          'https://example.com/login?shop=my-test-shop.myshopify.com'
        )
        Rails::Commands::Serve.new(@context).call
      end

      def test_update_env_with_host
        ShopifyCli::Tunnel.expects(:start).never
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example-foo.com'
        )
        command = Rails::Commands::Serve.new(@context)
        command.options.flags[:host] = 'https://example-foo.com'
        command.call
      end
    end
  end
end
