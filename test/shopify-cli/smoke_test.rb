# typed: ignore
require "test_helper"

module ShopifyCLI
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      assert_nothing_raised do
        capture_io do
          ShopifyCLI::Core::EntryPoint.call(["help"])
        end
      end
    end
  end
end
