# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    module DevServer
      class ReloadModeTest < Minitest::Test
        def test_default
          assert_equal :fast, ReloadMode.default
        end

        def test_get
          assert_equal :off, ReloadMode.get("off")
        end

        def test_get_when_enum_values_does_not_exist
          stub_context_messages

          io = capture_io_and_assert_raises(ShopifyCLI::AbortSilent) do
            ReloadMode.get("other")
          end

          io = io.join
          assert_match(/Error/, io)
          assert_match(/error message/, io)
          assert_match(/Try this/, io)
          assert_match(/help message/, io)
        end

        def test_values
          expected_values = [:fast, :"full-page", :off]
          actual_values = ReloadMode.values.sort

          assert_equal expected_values, actual_values
        end

        private

        def stub_context_messages
          stub_message.with("core.error").returns("Error")
          stub_message.with("core.try_this").returns("Try this")
          stub_message.with("theme.serve.reload_mode_is_not_valid", "other").returns("error message")
          stub_message.with("theme.serve.try_a_valid_reload_mode", anything).returns("help message")
        end

        def stub_message
          ShopifyCLI::Context.stubs(:message)
        end
      end
    end
  end
end
