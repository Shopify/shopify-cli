# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class GetAppsTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_loads_all_apps_into_a_list_from_organization
        test_org = {
          "id" => "1234567",
          "businessName" => "test business name",
          "apps" => [
            { "id" => 9940, "title" => "App One", "apiKey" => "1234", "apiSecretKeys" => [{ "secret" => "5678" }] },
          ],
        }
        stub_db_setup(organization_id: test_org["id"])
        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_apps).returns(test_org)

        app_list = Tasks::GetApps.call(context: @context)
        app = app_list.first

        assert_equal 1, app_list.size
        assert_equal "test business name", app.business_name
        assert_equal "App One", app.title
        assert_equal "1234", app.api_key
        assert_equal "5678", app.secret
      end

      def test_returns_empty_list_with_no_organization_id
        stub_db_setup(organization_id: nil)

        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch_with_apps).never
        assert_empty(Tasks::GetApps.call(context: @context))
      end

      def test_returns_empty_list_with_no_organization
        stub_db_setup(organization_id: "not-found")

        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_apps).returns(nil)
        assert_empty(Tasks::GetApps.call(context: @context))
      end

      def test_returns_empty_array_if_there_are_no_apps
        test_org = {
          "id" => 1234567,
          "businessName" => "test business name",
          "apps" => [],
        }
        stub_db_setup(organization_id: test_org["id"])
        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_apps).returns(test_org)

        assert_empty(Tasks::GetApps.call(context: @context))
      end
    end
  end
end
