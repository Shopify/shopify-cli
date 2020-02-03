require 'test_helper'

module ShopifyCli
  module Commands
    class Serve
      class NodeServeTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          project_context('app_types', 'node')
          Helpers::EnvFile.any_instance.stubs(:write)
          Helpers::EnvFile.any_instance.stubs(:update)
          @cmd = ShopifyCli::Commands::Serve
          @cmd.ctx = @context
        end

        def test_server_command
          ShopifyCli::Tasks::Tunnel.stubs(:call)
          ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
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
          @cmd.call([], 'serve')
        end
      end
    end
  end
end
