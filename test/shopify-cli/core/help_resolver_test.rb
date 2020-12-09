require 'test_helper'

module ShopifyCli
  module Core
    class HelpResolverTest < MiniTest::Test
      def test_outputs_help_with_help_flag
        ShopifyCli::Commands::Help.expects(:call)
        assert_raises(ShopifyCli::AbortSilent) { run_cmd('-h') }
      end

      def test_outputs_help_without_argument
        ShopifyCli::Commands::Help.expects(:call)
        run_cmd('')
      end
    end
  end
end
