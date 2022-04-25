# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class GetExtensionsTest < MiniTest::Test
      include ExtensionTestHelpers::Stubs::GetApp
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_return_empty_list_with_no_organization_id
        stub_db_setup(organization_id: nil)

        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch_with_extensions).never
        assert_empty(Tasks::GetExtensions.call(context: @context, type: extension_type))
      end

      def test_return_empty_list_with_no_organization
        stub_db_setup(organization_id: "not-found")

        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_extensions).returns(nil)
        assert_empty(Tasks::GetExtensions.call(context: @context, type: extension_type))
      end

      def test_return_empty_list_with_no_apps
        test_org = organization(name: "Test organization", apps: [])
        stub_db_setup(organization_id: test_org[:id])

        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_extensions).returns(test_org)
        assert_empty(Tasks::GetExtensions.call(context: @context, type: extension_type))
      end

      def test_return_empty_list_with_no_extension_registration
        test_app = { "id" => 9940, "title" => "App One", "apiKey" => "1234",
                     "apiSecretKeys" => [{ "secret" => "5678" }] }
        test_org = organization(name: "Test organization", apps: [test_app])
        stub_db_setup(organization_id: test_org[:id])

        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_extensions).returns(test_org)
        assert_empty(Tasks::GetExtensions.call(context: @context, type: extension_type))
      end

      def test_return_list_of_extensions_owned_by_organziation
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        organization_id = 1234567
        stub_db_setup(organization_id: organization_id)
        stub_fetch_with_extensions(organization_id)

        extensions_list = Tasks::GetExtensions.call(context: @context, type: extension_type)
        assert_equal 1, extensions_list.size
        assert_equal 2, extensions_list.first.size
        assert_instance_of(Extension::Models::App, extensions_list.dig(0, 0))
        assert_instance_of(Extension::Models::Registration, extensions_list.dig(0, 1))
      end

      private

      def stub_fetch_with_extensions(organization_id)
        test_org = {
          "id" => organization_id,
          "businessName" => "test business name",
          "apps" => [
            {
              "id" => 9940,
              "title" => "App One",
              "apiKey" => "1234",
              "apiSecretKeys" => [{ "secret" => "5678" }],
              "extensionRegistrations" => [
                { "id" => 3,
                  "uuid" => "1234",
                  "type" => extension_type,
                  "title" => "test extension name",
                  "draftVersion" => {
                    "registrationId" => 3,
                    "lastUserInteractionAt" => Time.now.to_s,
                  } },
              ],
            },
          ],
        }

        ShopifyCLI::PartnersAPI::Organizations.stubs(:fetch_with_extensions).returns(test_org)
      end

      def extension_type
        "THEME_APP_EXTENSION"
      end

      def stub_get_extension_registrations(app)
        stub_partner_req(
          "get_extension_registrations",
          variables: {
            "api_key": app["apiKey"],
            "type": extension_type,
          },
          resp: {
            data: {
              app: {
                "id": app["id"],
                "apiKey": app["apiKey"],
                "extensionRegistrations": [{ id: 3 }],
              },
            },
          },
        )
      end
    end
  end
end
