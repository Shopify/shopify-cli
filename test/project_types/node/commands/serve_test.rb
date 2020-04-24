require 'test_helper'

module Node
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        project_context('app_types', 'node')
        ShopifyCli::ProjectType.load_type(:node)
        ShopifyCli::Tasks::EnsureTestShop.stubs(:call)
        @context.stubs(:system)
      end

      def test_server_command
        ShopifyCli::Tunnel.stubs(:start).returns('https://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update)
        @context.expects(:system).with(
          'npm run dev',
          env: {
            "SHOPIFY_API_KEY" => "mykey",
            "SHOPIFY_API_SECRET" => "mysecretkey",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "read_products",
            "HOST" => "https://example.com",
            "PORT" => "8081",
          }
        )
        run_cmd('serve')
      end

      def test_server_command_with_invalid_host_url
        ShopifyCli::Tunnel.stubs(:start).returns('garbage://example.com')
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call).never
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).never
        @context.expects(:system).with(
          'npm run dev',
          env: {
            "SHOPIFY_API_KEY" => "mykey",
            "SHOPIFY_API_SECRET" => "mysecretkey",
            "SHOP" => "my-test-shop.myshopify.com",
            "SCOPES" => "read_products",
            "HOST" => "garbage://example.com",
            "PORT" => "8081",
          }
        ).never

        assert_raises ShopifyCli::Abort do
          run_cmd('serve')
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
          'https://example.com/auth?shop=my-test-shop.myshopify.com'
        )
        run_cmd('serve')
      end

      def test_update_env_with_host
        ShopifyCli::Tunnel.expects(:start).never
        ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
        ShopifyCli::Resources::EnvFile.any_instance.expects(:update).with(
          @context, :host, 'https://example-foo.com'
        )
        run_cmd('serve --host="https://example-foo.com"')
      end
    end
  end
end
