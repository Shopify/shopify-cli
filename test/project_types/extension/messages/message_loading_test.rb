# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Messages
    class MessageLoadingTest < MiniTest::Test
      include ExtensionTestHelpers
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @fake_messages = {
          name: "Fake Type",
          tagline: "Fake tagline",
        }

        @fake_overrides = {
          build: {
            frame_title: "Overridden Title",
          },
        }

        @fake_override_messages = @fake_messages.merge(overrides: @fake_overrides)
      end

      def test_load_returns_default_messages_if_no_type_messages_exist
        Messages::MessageLoading.expects(:load_current_type_messages).returns(nil).once
        Messages::MESSAGES.expects(:merge).never

        assert_equal Messages::MESSAGES, Messages::MessageLoading.load
      end

      def test_load_returns_default_messages_if_type_messages_exist_with_no_overrides
        Messages::MessageLoading.expects(:load_current_type_messages).returns(@fake_messages).once
        Messages::MESSAGES.expects(:merge).never

        assert_equal Messages::MESSAGES, Messages::MessageLoading.load
      end

      def test_load_returns_default_messages_merged_with_overrides_if_types_messages_exist_and_have_overrides
        Messages::MessageLoading.expects(:load_current_type_messages).returns(@fake_override_messages).once

        loaded_messages = Messages::MessageLoading.load
        assert_equal @fake_overrides[:build][:frame_title], loaded_messages[:build][:frame_title]
      end

      def test_load_does_a_deep_merge_and_retains_nested_non_overridden_messages
        Messages::MessageLoading.expects(:load_current_type_messages).returns(@fake_override_messages).once

        loaded_messages = Messages::MessageLoading.load
        refute_nil loaded_messages[:build][:build_failure_message]
        assert_equal Messages::MESSAGES[:build][:build_failure_message], loaded_messages[:build][:build_failure_message]
      end

      def test_load_current_type_messages_returns_nil_if_there_is_no_current_project
        ShopifyCLI::Project.expects(:has_current?).returns(false).once

        assert_nil(Messages::MessageLoading.load_current_type_messages)
      end

      def test_load_current_type_messages_calls_messages_for_type_with_type_if_there_is_a_current_project
        project = ExtensionTestHelpers.fake_extension_project(with_mocks: true)

        ShopifyCLI::Project.expects(:has_current?).returns(true).once
        ShopifyCLI::Project.stubs(:current).returns(project).once
        Messages::MessageLoading.expects(:messages_for_type).with(project.type).once

        Messages::MessageLoading.load_current_type_messages
      end

      def test_messages_for_type_returns_nil_if_the_type_identifier_is_nil
        assert_nil(Messages::MessageLoading.messages_for_type(nil))
      end

      def test_messages_for_type_returns_nil_if_the_type_key_does_not_exist
        project = ExtensionTestHelpers.fake_extension_project(with_mocks: true)

        Messages::TYPES.expects(:key?).with(project.type.downcase.to_sym).returns(false).once

        assert_nil(Messages::MessageLoading.messages_for_type(project.type))
      end

      def test_messages_for_type_returns_type_messages_if_they_exist
        project = ExtensionTestHelpers.fake_extension_project(with_mocks: true)

        Messages::TYPES.expects(:key?).with(project.type.downcase.to_sym).returns(true).once
        Messages::TYPES.expects(:[]).with(project.type.downcase.to_sym).returns(@fake_overrides).once

        assert_equal @fake_overrides, Messages::MessageLoading.messages_for_type(project.type)
      end
    end
  end
end
