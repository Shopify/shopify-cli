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

      def test_returns_defined_attributes_if_valid
        form = ask
        assert_equal form.name, 'test-extension'
        assert_equal form.type, @test_extension_type
      end

      def test_prompts_the_user_to_choose_a_name_if_no_name_was_provided
        CLI::UI::Prompt.expects(:ask).with(Content::Create::ASK_NAME).times(3).returns('A name')
        capture_io { ask(name: nil) }
        capture_io { ask(name: "") }
        capture_io { ask(name: " ") }
      end

      def test_reprompts_the_user_to_choose_a_name_until_valid_response_is_given
        CLI::UI::Prompt.stubs(:ask).with(Content::Create::ASK_NAME)
          .returns(nil, nil)
          .then.returns('A name')
        ShopifyCli::Context.any_instance.expects(:puts).with(
          Content::Create::INVALID_NAME % Models::Registration::MAX_TITLE_LENGTH
        ).times(2)

        capture_io do
          form = ask(name: nil)
          assert_equal form.name, 'A name'
        end
      end

      def test_strips_whitespace_from_beginning_and_end_of_name
        CLI::UI::Prompt.expects(:ask).with(Content::Create::ASK_NAME).returns('  A name  ')
        capture_io do
          form = ask(name: nil)
          assert_equal form.name, 'A name'
        end
      end

      def test_directory_name_is_a_lowercase_underscored_version_of_name
        assert_equal 'demo', ask(name: 'Demo').directory_name
        assert_equal 'spaces', ask(name: ' Spaces ').directory_name
        assert_equal 'demo_extension', ask(name: 'Demo Extension').directory_name
        assert_equal 'testlongstring', ask(name: 'TestLongString').directory_name
        assert_equal 'double__spaces', ask(name: 'double  spaces').directory_name
      end

      def test_accepts_any_valid_extension_type
        form = ask(type: @test_extension_type.identifier)
        assert_equal form.type, @test_extension_type
      end

      def test_outputs_an_error_and_prompts_the_user_to_choose_a_type_if_an_unknown_type_was_provided_as_flag
        CLI::UI::Prompt
          .expects(:interactive_prompt)
          .returns("#{@test_extension_type.name} #{@test_extension_type.tagline}")
          .once

        io = capture_io { ask(type: 'unknown-type') }

        assert_match(Content::Create::INVALID_TYPE, io.join)
        assert_match(Content::Create::ASK_TYPE, io.join)
      end

      def test_prompts_the_user_to_choose_a_type_if_no_type_was_provided
        CLI::UI::Prompt.expects(:ask).with(Content::Create::ASK_TYPE)

        capture_io do
          ask(type: nil)
        end
      end

      def test_aborts_and_informs_user_if_there_are_no_apps
        Tasks::GetApps.any_instance.unstub(:call)
        Tasks::GetApps.any_instance.expects(:call).with(context: @context).returns([]).once
        @context.expects(:abort).with(Content::Create::NO_APPS).raises(ShopifyCli::Abort).once

        capture_io { ask }
      end

      def test_accepts_the_api_key_to_associate_with_extension
        form = ask(api_key: '1234')
        assert_equal form.app, @app
      end

      def test_prompts_the_user_to_choose_an_app_to_associate_with_extension_if_no_app_is_provided
        CLI::UI::Prompt.expects(:ask).with(Content::Create::ASK_APP)

        capture_io do
          ask(api_key: nil)
        end
      end

      def test_fails_with_invalid_api_key_to_associate_with_extension
        api_key = '00001'

        io = capture_io { ask(api_key: api_key) }

        assert_match(Content::Create::INVALID_API_KEY % api_key, io.join)
      end

      private

      def ask(name: 'test-extension', type: @test_extension_type.identifier, api_key: @app.api_key)
        Create.ask(
          @context,
          [],
          name: name,
          type: type,
          api_key: api_key,
        )
      end
    end
  end
end
