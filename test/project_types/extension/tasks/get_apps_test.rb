# typed: ignore
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
        @app = Models::App.new(title: "App One", api_key: "1234", secret: "5678")
      end

      def test_loads_all_apps_into_a_list_from_organizations
        stub_get_organizations([
          organization(name: "Organization One", apps: [@app]),
        ])

        app_list = Tasks::GetApps.call(context: @context)
        app = app_list.first

        assert_equal 1, app_list.size
        assert_equal "Organization One", app.business_name
        assert_equal "App One", app.title
        assert_equal "1234", app.api_key
        assert_equal "5678", app.secret
      end

      def test_returns_empty_array_if_there_are_no_organizations
        stub_get_organizations([])

        assert_empty(Tasks::GetApps.call(context: @context))
      end

      def test_returns_empty_array_if_there_are_no_apps
        stub_get_organizations([
          organization(name: "Organization One", apps: []),
        ])

        assert_empty(Tasks::GetApps.call(context: @context))
      end

      def test_can_handle_multiple_organizations_where_one_has_no_apps
        stub_get_organizations([
          organization(name: "Organization One", apps: [@app]),
          organization(name: "Organization Two", apps: []),
        ])

        assert_equal 1, Tasks::GetApps.call(context: @context).size
      end
    end
  end
end
