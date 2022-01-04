# typed: ignore
require "test_helper"

module ShopifyCLI
  module Core
    class HelpResolverTest < MiniTest::Test
      def test_outputs_help_with_help_flag
        ShopifyCLI::Commands::Help.expects(:call)
        assert_raises(ShopifyCLI::AbortSilent) do
          run_cmd("-h")
        end
      end

      def test_outputs_help_without_argument
        ShopifyCLI::Commands::Help.expects(:call)
        run_cmd("")
      end
    end
  end
end
