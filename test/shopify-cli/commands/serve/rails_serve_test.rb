require 'test_helper'

module ShopifyCli
  module Commands
    class Serve
      class RailsServeTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          project_context('app_types', 'rails')
          Helpers::EnvFile.any_instance.stubs(:write)
          Helpers::EnvFile.any_instance.stubs(:update)
          @cmd = ShopifyCli::Commands::Serve
          @cmd.ctx = @context
        end

        def test_server_command
          ShopifyCli::Tasks::Tunnel.stubs(:call)
          ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
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
          @cmd.call([], 'serve')
        end
      end
    end
  end
end
