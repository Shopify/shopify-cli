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
        Shopifolk.stubs(:check)
      end

      def test_create_new_app_if_none_available
        response = [{
          "id" => 421,
          "businessName" => "one",
          "stores" => [{
            "shopDomain" => "store.myshopify.com",
          }],
          "apps" => [],
        }]
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(response)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.app_name')).returns('new app')
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.app_type.select')).returns('public')
        ShopifyCli::Tasks::CreateApiClient.expects(:call).with(
          @context,
          org_id: 421,
          title: 'new app',
          type: 'public',
        ).returns({
          "apiKey" => 1235,
          "apiSecretKeys" => [{ "secret" => 1234 }],
          "id" => "12345678",
        })
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal response.first, EnsureEnv.call(@context)
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
            "apiKey" => 1235,
            "apiSecretKeys" => [{
              "secret" => 1234,
            }],
          }],
        }]
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(response)
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal response.first, EnsureEnv.call(@context)
      end

      def test_uses_default_values_for_env_file
        Resources::EnvFile.expects(:parse_external_env).raises(Errno::ENOENT)
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(partners_api_response)
        expect_user_prompts
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal partners_api_response[1], EnsureEnv.call(@context)
      end

      def test_keep_existing_env_values
        Resources::EnvFile.expects(:parse_external_env).returns({ host: "host" })
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(partners_api_response)
        expect_user_prompts
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values.merge({ host: "host" })).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal partners_api_response[1], EnsureEnv.call(@context)
      end

      def test_not_all_required_values_found
        Resources::EnvFile.expects(:parse_external_env).returns(existing_env_file_values)
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(partners_api_response)
        expect_user_prompts
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal partners_api_response[1], EnsureEnv.call(@context, required: [:api_key, :secret, :shop])
      end

      def test_all_required_values_found
        Resources::EnvFile.expects(:parse_external_env).returns(existing_env_file_values)
        Resources::EnvFile.expects(:new).never
        assert_empty(EnsureEnv.call(@context))
      end

      def test_regenerate_existing_env_file
        Resources::EnvFile
          .expects(:parse_external_env)
          .returns(existing_env_file_values.merge({ shop: "shop", host: "host" }))
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(partners_api_response)
        expect_user_prompts
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values.merge({ host: "host" })).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal partners_api_response[1], EnsureEnv.call(@context, regenerate: true)
      end

      def test_regenerate_empty_env_file
        Resources::EnvFile.expects(:parse_external_env).returns({})
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns(partners_api_response)
        expect_user_prompts
        env_file = Minitest::Mock.new
        Resources::EnvFile.expects(:new).with(new_env_file_values).returns(env_file)
        env_file.expect(:write, nil, [@context])
        assert_equal partners_api_response[1], EnsureEnv.call(@context, regenerate: true)
      end

      private

      def expect_user_prompts
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.tasks.ensure_env.organization_select')).returns(101)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message('core.tasks.ensure_env.development_store_select')
        ).returns('store.myshopify.com')
      end

      def new_env_file_values
        {
          api_key: 1235,
          secret: 1234,
          shop: "store.myshopify.com",
          scopes: "write_products,write_customers,write_draft_orders",
          extra: {},
        }
      end

      def existing_env_file_values
        { api_key: "apikey", secret: "secret" }
      end

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
