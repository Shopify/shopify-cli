require 'test_helper'

module ShopifyCli
  class HelpResolverTest < MiniTest::Test
    def test_outputs_help_with_help_flag
      ShopifyCli::Commands::Help.expects(:call)
      assert_raises(ShopifyCli::AbortSilent) do
        run_cmd('-h')
      end
    end
  end
end
