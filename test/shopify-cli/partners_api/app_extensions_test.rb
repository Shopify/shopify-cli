# frozen_string_literal: true

require "test_helper"

module ShopifyCLI
  class PartnersAPI
    class AppExtensionsTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        @type = "THEME_APP_EXTENSION"
      end

      def test_fetch_apps_extensions
        stub_get_extension_registrations

        org = PartnersAPI::AppExtensions.fetch_apps_extensions(@context, fake_org, @type)
        apps = org["apps"]
        app = apps.first
        registration = app["extensionRegistrations"].first

        assert_equal(1, apps.size)
        assert_equal(2, app["id"])
        assert_equal(3, app["apiKey"])
        assert_equal(1, app["extensionRegistrations"].size)
        assert_equal(4, registration["id"])
        assert_equal(5, registration["draftVersion"]["registrationId"])
      end

      private

      def fake_org
        fake_app = { "apiKey" => 3 }
        { "apps" => [fake_app] }
      end

      def stub_get_extension_registrations
        stub_partner_req(
          "get_extension_registrations",
          variables: {
            api_key: 3,
            type: @type,
          },
          resp: {
            data: {
              app: {
                id: 2,
                apiKey: 3,
                extensionRegistrations: [
                  {
                    id: 4,
                    draftVersion: { registrationId: 5 },
                  },
                ],
              },
            },
          },
        )
      end
    end
  end
end
