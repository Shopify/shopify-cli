# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Forms
    class RegisterTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TestExtensionSetup
      include ExtensionTestHelpers::Messages

      def setup
        super
        @app = Models::App.new(title: 'Fake', api_key: '1234', secret: '4567', business_name: 'Fake Business')
      end

      def test_aborts_and_informs_user_if_there_are_no_apps
        Tasks::GetApps.any_instance.expects(:call).with(context: @context).returns([]).once

        io = capture_io { assert_raises(ShopifyCli::AbortSilent) { ask(api_key: nil) } }

        assert_message_output(
          io: io,
          expected_content: [@context.message('register.no_apps'), @context.message('register.learn_about_apps')],
        )
      end

      def test_accepts_the_api_key_and_fetches_single_app_to_associate_with_extension
        Tasks::GetApps.any_instance.expects(:call).never
        Tasks::GetApp.any_instance.expects(:call).with(context: @context, api_key: @app.api_key).returns(@app).once

        form = ask(api_key: @app.api_key)
        assert_equal form.app, @app
      end

      def test_prompts_the_user_to_choose_an_app_to_associate_with_extension_if_no_app_is_provided
        Tasks::GetApp.any_instance.expects(:call).never
        Tasks::GetApps.any_instance.expects(:call).with(context: @context).returns([@app]).once
        CLI::UI::Prompt.expects(:ask).with(@context.message('register.ask_app'))

        capture_io { ask(api_key: nil) }
      end

      def test_fails_with_invalid_api_key_to_associate_with_extension
        api_key = '00001'

        Tasks::GetApps.any_instance.expects(:call).never
        Tasks::GetApp.any_instance.expects(:call).with(context: @context, api_key: api_key).returns(nil).once

        io = capture_io { ask(api_key: api_key) }

        assert_match(@context.message('register.invalid_api_key', api_key), io.join)
      end

      private

      def ask(api_key: @app.api_key)
        Register.ask(@context, [], api_key: api_key)
      end
    end
  end
end
