require 'test_helper'

module ShopifyCli
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      assert_nothing_raised { capture_io { ShopifyCli::Core::EntryPoint.call(%w[help]) } }
    end
  end
end
