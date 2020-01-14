require 'test_helper'

module ShopifyCli
  class AppTypeCommandTest < MiniTest::Test
    def test_non_existant_command
      assert_raises(ShopifyCli::Abort) do
        run_cmd('serve')
      end
    end
  end
end
