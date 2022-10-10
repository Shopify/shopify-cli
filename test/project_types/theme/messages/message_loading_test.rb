# frozen_string_literal: true
require "test_helper"

module Theme
  module Messages
    class MessageLoadingTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:theme)
      end

      def test_original_messages_refer_to_cli2_commands
        messages = Theme::Messages.all

        assert_match(/%s theme serve/, messages.dig(:theme, :serve, :auth, :error_message))
        assert_match(/%s logout/, messages.dig(:theme, :serve, :auth, :help_message))
      end

      def test_new_messages_refer_to_cli3_commands
        ShopifyCLI::Environment.expects(:run_as_subprocess?).returns(true)
        messages = Theme::Messages.all

        assert_match(/%s theme dev/, messages.dig(:theme, :serve, :auth, :error_message))
        assert_match(/%s auth logout/, messages.dig(:theme, :serve, :auth, :help_message))
      end
    end
  end
end
