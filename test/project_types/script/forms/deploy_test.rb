# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class DeployTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def test_use_provided_app
        form = ask(api_key: 'fakekey')
        assert_equal(form.api_key, 'fakekey')
      end

      def test_ask_calls_form_ask_app_api_key_when_no_flag
        apps = [{ "apiKey" => 1234 }]
        Deploy.any_instance.expects(:ask_app_api_key).with(@context, apps)
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_with_app).with(@context).returns([{ "apps" => apps }])
        ask
      end

      def test_organizations_fetch_once
        UI::StrictSpinner.expects(:spin).with('Fetching organizations').yields(FakeSpinner.new).returns(true).once
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).once
        form = Deploy.new(@context, [], [])
        2.times { form.send(:organizations) }
      end

      def test_no_apps_raises_error
        Deploy.any_instance.stubs(:organization).returns({ "apps" => [] })
        assert_raises(Errors::NoExistingAppsError) { ask }
      end

      def test_no_organization_raises_error
        Deploy.any_instance.stubs(:organizations).returns([])
        assert_raises(Errors::NoExistingOrganizationsError) { ask }
      end

      private

      def ask(api_key: nil)
        Deploy.ask(
          @context,
          [],
          api_key: api_key
        )
      end
    end
  end
end
