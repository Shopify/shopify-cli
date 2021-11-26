# frozen_string_literal: true

require "test_helper"
require "timecop"
require "shopify_cli/theme/syncer"

module ShopifyCLI
  module Theme
    class Syncer
      class OperationTest < Minitest::Test
        def setup
          super
          @ctx = TestHelpers::FakeContext.new
          file = stub(relative_path: "sections/apps.liquid")
          @operation = Operation.new(@ctx, "update", file)
        end

        def test_as_error_message
          @ctx.stubs(:message).with("theme.serve.operation.status.error")
            .returns("ERROR")

          time_freeze do
            assert_message("{{red:ERROR }}", @operation.as_error_message)
          end
        end

        def test_as_synced_message
          @ctx.stubs(:message).with("theme.serve.operation.status.synced")
            .returns("Synced")

          time_freeze do
            assert_message("{{green:Synced}}", @operation.as_synced_message)
          end
        end

        def test_as_fix_message
          @ctx.stubs(:message).with("theme.serve.operation.status.fixed")
            .returns("Fixed")

          time_freeze do
            assert_message("{{cyan:Fixed }}", @operation.as_fix_message)
          end
        end

        def test_to_s
          assert_equal("update sections/apps.liquid", @operation.to_s)
        end

        def test_to_s_when_file_is_nil
          @operation.file = nil
          assert_equal("update ", @operation.to_s)
        end

        private

        def assert_message(status, actual_message)
          expected_message = "12:30:59 #{status} {{>}} {{blue:update sections/apps.liquid}}"
          assert_equal expected_message, actual_message
        end

        def time_freeze(&block)
          time = Time.local(2000, 1, 1, 12, 30, 59)
          Timecop.freeze(time, &block)
        end
      end
    end
  end
end
