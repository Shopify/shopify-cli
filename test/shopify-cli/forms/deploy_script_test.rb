# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class DeployScriptTest < MiniTest::Test
      include TestHelpers::Partners

      def test_use_provided_app
        form = ask(api_key: 'fakekey')
        assert_equal(form.api_key, 'fakekey')
      end

      def test_pick_singular_app
        Helpers::Organizations.stubs(:fetch_apps).with(@context).returns([{ "apiKey" => 1234 }])
        form = ask
        assert_equal 1234, form.api_key
      end

      def test_display_selection_for_apps
        Helpers::Organizations.stubs(:fetch_apps).with(@context).returns(
          [{ "apiKey" => 1234 }, { "apiKey" => 1267 }]
        )
        CLI::UI::Prompt.expects(:ask)
          .with(
            'Which app do you want this script to belong to?'
          )
          .returns(1267)
        form = ask
        assert_equal(form.api_key, 1267)
      end

      def test_show_error_when_no_apps_exist
        Helpers::Organizations.stubs(:fetch_apps).with(@context).returns([])
        io = capture_io do
          assert_nil(ask)
        end
        assert(io.join.start_with?("\e[0;31m✗\e[0m You need to create an app first"))
      end

      private

      def ask(api_key: nil)
        DeployScript.ask(
          @context,
          [],
          api_key: api_key
        )
      end
    end
  end
end
