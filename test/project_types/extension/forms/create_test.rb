# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TestExtensionSetup

      def setup
        super
        @app = Models::App.new(title: 'Fake', api_key: '1234', secret: '4567', business_name: 'Fake Business')
        Tasks::GetApps.any_instance.expects(:call).with(context: @context).returns([@app]).at_least_once
      end

      def returns_defined_attributes_if_valid
        form = ask
        assert_equal form.title, 'test-extension'
        assert_equal form.type, @test_extension_type.identifier
      end

      def test_prompts_the_user_to_choose_a_title_if_no_title_was_provided
        CLI::UI::Prompt.expects(:ask).with(Forms::Create::ASK_TITLE).times(3)

        capture_io { ask(title: nil) }
        capture_io { ask(title: "") }
        capture_io { ask(title: " ") }
      end

      def test_name_is_a_lowercase_underscored_version_of_title
        assert_equal 'demo', ask(title: 'Demo').name
        assert_equal 'spaces', ask(title: ' Spaces ').name
        assert_equal 'demo_extension', ask(title: 'Demo Extension').name
        assert_equal 'testlongstring', ask(title: 'TestLongString').name
      end

      def test_accepts_any_valid_extension_type
        form = ask(type: @test_extension_type.identifier)
        assert_equal form.type, @test_extension_type.identifier
      end

      def test_prompts_the_user_to_choose_a_type_if_an_unknown_type_was_provided_as_flag
        CLI::UI::Prompt::expects(:ask).with(Forms::Create::ASK_TYPE)

        io = capture_io do
          ask(type: 'unknown-type')
        end

        assert_match(Forms::Create::INVALID_TYPE, io.join)
      end

      def test_prompts_the_user_to_choose_a_type_if_no_type_was_provided
        CLI::UI::Prompt.expects(:ask).with(Forms::Create::ASK_TYPE)

        capture_io do
          ask(type: nil)
        end
      end

      def test_informs_user_if_there_are_no_apps
        Tasks::GetApps.any_instance.unstub(:call)
        Tasks::GetApps.any_instance.expects(:call).with(context: @context).returns([]).once

        output = capture_io { ask }

        assert_match Forms::Create::NO_APPS, output.join
      end

      def test_accepts_the_api_key_to_associate_with_extension
        form = ask(api_key: '1234')
        assert_equal form.app, @app
      end

      def test_prompts_the_user_to_choose_an_app_to_associate_with_extension_if_no_app_is_provided
        CLI::UI::Prompt.expects(:ask).with(Forms::Create::ASK_APP)

        capture_io do
          ask(api_key: nil)
        end
      end

      def test_fails_with_invalid_api_key_to_associate_with_extension
        io = capture_io do
          ask(api_key: '00001')
        end

        assert_match(Forms::Create::INVALID_API_KEY, io.join)
      end

      private

      def ask(title: 'test-extension', type: @test_extension_type.identifier, api_key: @app.api_key)
        Create.ask(
          @context,
          [],
          title: title,
          type: type,
          api_key: api_key,
        )
      end
    end
  end
end
