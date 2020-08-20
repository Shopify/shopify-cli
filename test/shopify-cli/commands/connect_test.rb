require 'test_helper'

module ShopifyCli
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners

      def test_connect_asks_project_type_and_writes_yml_when_no_project_exists
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('node')
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
        ShopifyCli::Project.any_instance.expects(:clear_env)
        ShopifyCli::Project.expects(:write)
        run_cmd('connect')
      end

      def test_connect_doesnt_write_yml_when_current_project_exists
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).never
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
        ShopifyCli::Project.any_instance.expects(:clear_env)
        ShopifyCli::Project.expects(:write).never
        run_cmd('connect')
      end

      def test_connect_outputs_warnings_if_already_connected
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).never
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
        ShopifyCli::Project.any_instance.expects(:clear_env)
        ShopifyCli::Project.expects(:write).never
        ShopifyCli::Project.stubs(:current_project_type).returns(:rails)

        @context.expects(:puts).with(@context.message('core.connect.already_connected_warning'))
        @context.expects(:puts).with(@context.message('core.connect.production_warning'))
        @context.expects(:puts).with(@context.message('core.connect.connected', 'app'))

        run_cmd('connect')
      end

      private

      def org_response
        {
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
        }
      end
    end
  end
end
