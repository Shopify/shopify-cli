require 'test_helper'

module Shopifyli
  class SmokeTest < MiniTest::Test
    def test_exit_non_zero
      capture_io do
        assert_nil ShopifyCli::EntryPoint.call(['help'])
      end
    end
  end
end
