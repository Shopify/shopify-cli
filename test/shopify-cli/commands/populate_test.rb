require 'test_helper'

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      def setup
        super
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        Tasks::Schema.stubs(:call)
        Tasks::EnsureEnv.stubs(:call)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        run_cmd('populate')
      end
    end
  end
end
