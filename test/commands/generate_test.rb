require 'test_helper'

module ShopifyCli
  module Commands
    class GenerateTest  < MiniTest::Test
      include TestHelpers::AppType

      def setup
        super
        @command = ShopifyCli::Commands::Generate.new(@context)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Generate.help)
        @command.call([], nil)
      end
    end
  end
end
