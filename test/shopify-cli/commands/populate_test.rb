require 'test_helper'

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Populate.new(@context)
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        @command.call([], nil)
      end
    end
  end
end
