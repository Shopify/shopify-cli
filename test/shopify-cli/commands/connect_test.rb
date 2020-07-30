require 'test_helper'

module ShopifyCli
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners

      def test_connect_asks_project_type_and_writes_yml_when_no_project_exists
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        Resources::EnvFile.expects(:parse_external_env).returns({})
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('node')
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')

        Resources::EnvFile.any_instance.expects(:write)
        ShopifyCli::Project.expects(:write)
        run_cmd('connect')
      end

      def test_connect_doesnt_write_yml_when_current_project_exists
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')

        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).never
        Resources::EnvFile.any_instance.expects(:write)
        ShopifyCli::Project.expects(:write).never
        run_cmd('connect')
      end

      def test_connect_adds_to_env_file_if_already_exists
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        Resources::EnvFile.expects(:parse_external_env).returns({
          scopes: 'read_products',
          extra: { "additional" => "things" },
        })
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('node')
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')

        Resources::EnvFile.expects(:new).with(
          api_key: "apikey",
          secret: 1234,
          shop: "store.myshopify.com",
          scopes: "read_products",
          extra: { "additional" => "things" }
        ).returns(stub(:write))
        ShopifyCli::Project.expects(:write)
        run_cmd('connect')
      end

      def test_connect_outputs_warnings_if_already_connected
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).never
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')
        Resources::EnvFile.any_instance.expects(:write)
        ShopifyCli::Project.expects(:write).never
        ShopifyCli::Project.stubs(:current_project_type).returns(:rails)

        @context.expects(:puts).with(@context.message('core.connect.already_connected_warning'))
        @context.expects(:puts).with(@context.message('core.connect.production_warning'))
        @context.expects(:puts).with(@context.message('core.connect.connected', 'app'))

        run_cmd('connect')
      end

      private

      def partners_api_response
        [{
          "id" => 100,
          "businessName" => "one",
          "stores" => [{
            "shopDomain" => "store.myshopify.com",
          }],
          "apps" => [{
            "title" => "app",
            "apiKey" => "apikey",
            "apiSecretKeys" => [{
              "secret" => 1233,
            }],
          }],
        }, {
          "id" => 101,
          "businessName" => "two",
          "stores" => [
            { "shopDomain" => "store2.myshopify.com", "shopName" => "foo" },
            { "shopDomain" => "store1.myshopify.com", "shopName" => "bar" },
          ],
          "apps" => [{
            "title" => "app",
            "apiKey" => "apikey",
            "apiSecretKeys" => [{
              "secret" => 1234,
            }],
          }],
        }]
      end
    end
  end
end
