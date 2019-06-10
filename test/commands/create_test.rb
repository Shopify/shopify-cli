require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @command = ShopifyCli::Commands::Create.new(@context)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        @command.call([], nil)
      end
    end
  end
end
