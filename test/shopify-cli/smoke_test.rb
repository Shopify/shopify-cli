require 'test_helper'

module ShopifyCli
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      assert_nothing_raised do
        ShopifyCli::EntryPoint.call(['help'])
      end
    end
  end
end
