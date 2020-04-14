require 'test_helper'

module ShopifyCli
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      assert_nothing_raised do
        capture_io do
          ShopifyCli::Core::EntryPoint.call(['help'])
        end
      end
    end
  end
end
