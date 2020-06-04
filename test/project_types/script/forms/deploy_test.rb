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
        Deploy.any_instance.expects(:ask_app_api_key).with(apps)
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).with(@context).returns([{ "apps" => apps }])
        ask
      end

      def test_calls_superclass_methods_when_no_flags
        ScriptForm.any_instance.stubs(:organization).returns({})
        ScriptForm.any_instance.expects(:ask_app_api_key).once
        ask(api_key: nil)
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
