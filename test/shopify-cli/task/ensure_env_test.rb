require 'test_helper'

module ShopifyCli
  module Tasks
    class EnsureEnvTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        root = Dir.mktmpdir
        @context = TestHelpers::FakeContext.new(root: root)
        Project.write(@context, project_type: :fake, organization_id: 42)
        FileUtils.cd(@context.root)
        ShopifyCli::Tunnel.stubs(:start)
      end

      def test_create_new_app_if_none_available
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns([{
          "id" => 421,
          "businessName" => "one",
          "stores" => [{
            "shopDomain" => "store.myshopify.com",
          }],
          "apps" => [],
        }])
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.app_name')).returns('new app')
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.app_type.select')).returns('public')
        ShopifyCli::Tasks::CreateApiClient.expects(:call).with(
          @context,
          org_id: 421,
          title: 'new app',
          type: 'public',
        ).returns({
          "apiKey" => "ljdlkajfaljf",
          "apiSecretKeys" => [{ "secret" => "kldjakljjkj" }],
          "id" => "12345678",
        })
        Resources::EnvFile.any_instance.stubs(:write)
        EnsureEnv.call(@context)
      end

      def test_no_prompt_if_one_app_and_org
        response = [{
          "id" => 421,
          "businessName" => "one",
          "stores" => [{
            "shopDomain" => "store.myshopify.com",
          }],
          "apps" => [{
            "title" => "app",
            "apiKey" => 1234,
            "apiSecretKeys" => [{
              "secret" => 1233,
            }],
          }],
        }]
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(response)
        Resources::EnvFile.any_instance.stubs(:write)
        EnsureEnv.call(@context)
      end

      def test_uses_default_values_for_env_file
        Resources::EnvFile.expects(:parse_external_env).with.raises(Errno::ENOENT)
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')

        Resources::EnvFile.expects(:new).with(
          api_key: 1235,
          secret: 1234,
          shop: "store.myshopify.com",
          scopes: "write_products,write_customers,write_draft_orders",
          extra: {}
        ).returns(stub(:write))
        EnsureEnv.call(@context)
      end

      def test_keep_existing_env_values
        Resources::EnvFile.expects(:parse_external_env).with.returns({ host: "host" })
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).returns(partners_api_response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')

        Resources::EnvFile.expects(:new).with(
          api_key: 1235,
          secret: 1234,
          shop: "store.myshopify.com",
          scopes: "write_products,write_customers,write_draft_orders",
          host: "host",
          extra: {}
        ).returns(stub(:write))
        EnsureEnv.call(@context)
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
            "apiKey" => 1234,
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
            "apiKey" => 1235,
            "apiSecretKeys" => [{
              "secret" => 1234,
            }],
          }],
        }]
      end
    end
  end
end
