require "test_helper"

module ShopifyCli
  class ConnectTest < MiniTest::Test
    include TestHelpers::Partners

    def test_runs_default_behaviour_if_no_connect_command
      ShopifyCli::Project.stubs(:has_current?).returns(false)
      ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
      ShopifyCli::Project.expects(:write)
      ShopifyCli::Connect.new(@context).default_connect("project_type")
    end

    def test_not_write_yml_when_current_project_exists_in_default
      ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
      ShopifyCli::Project.expects(:write).never
      ShopifyCli::Connect.new(@context).default_connect("project_type")
    end

    def test_outputs_warnings_if_already_connected_in_default
      context = ShopifyCli::Context.new

      context.expects(:puts).with(context.message("core.connect.already_connected_warning"))
      ShopifyCli::Tasks::EnsureEnv.expects(:call).with(context, regenerate: true).returns(org_response)
      ShopifyCli::Project.expects(:write).never

      ShopifyCli::Connect.new(context).default_connect("project_type")
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
