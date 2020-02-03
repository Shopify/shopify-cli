require 'test_helper'

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      def setup
        super
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        Tasks::Schema.stubs(:call)
        Tasks::EnsureEnv.stubs(:call)
        @cmd = ShopifyCli::Commands::Populate
        @cmd.ctx = @context
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        @cmd.call([], 'populate')
      end
    end
  end
end
