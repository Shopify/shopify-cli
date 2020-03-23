require 'test_helper'

module Rails
  module Commands
    class GenerateTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:rails)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Commands::Generate.help)
        run_cmd('generate')
      end
    end
  end
end
