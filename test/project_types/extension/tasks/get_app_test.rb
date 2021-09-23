# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class GetAppTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::GetApp
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        setup_temp_project
        @app = Models::App.new(title: "App One", api_key: "1234", secret: "5678")
      end

      def test_loads_app_into_a_single_app_model
        stub_get_app(api_key: @app.api_key, app: @app)

        app = Tasks::GetApp.call(context: @context, api_key: @app.api_key)

        assert_equal "App One", app.title
        assert_equal "1234", app.api_key
        assert_equal "5678", app.secret
      end

      def test_returns_nil_if_the_app_was_not_found
        stub_get_app(api_key: @app.api_key, app: nil)

        assert_nil(Tasks::GetApp.call(context: @context, api_key: @app.api_key))
      end
    end
  end
end
