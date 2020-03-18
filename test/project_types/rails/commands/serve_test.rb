require 'test_helper'

module Rails
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context('app_types', 'rails')
        ShopifyCli::ProjectType.load_type(:rails)
        @context.stubs(:system)
      end

      def test_server_command
        ShopifyCli::Tasks::Tunnel.stubs(:call)
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Helpers::EnvFile.any_instance.expects(:update)
        @context.expects(:system).with(
          'bin/rails server',
          env: {
            "SHOPIFY_API_KEY" => "api_key",
            "SHOPIFY_API_SECRET" => "secret",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "write_products,write_customers,write_orders",
            'PORT' => '8081',
          }
        )
        run_cmd('serve')
      end

      def test_open_while_run
        ShopifyCli::Context.any_instance.stubs(:on_siginfo).yields
        ShopifyCli::Tasks::Tunnel.stubs(:call).returns('https://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Helpers::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example.com'
        )
        ShopifyCli::Context.any_instance.stubs(:mac?).returns(true)
        ShopifyCli::Context.any_instance.expects(:open_url!).with(
          'https://example.com/login?shop=my-test-shop.myshopify.com'
        )
        run_cmd('serve')
      end

      def test_update_env_with_host
        ShopifyCli::Tasks::Tunnel.expects(:call).never
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Helpers::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example-foo.com'
        )
        run_cmd('serve --host="https://example-foo.com"')
      end
    end
  end
end
