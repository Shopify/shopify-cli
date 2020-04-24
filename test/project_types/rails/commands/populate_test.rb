require 'test_helper'

module Rails
  module Commands
    class PopulateTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Project.stubs(:current_project_type).returns(:rails)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Commands::Populate.help)
        run_cmd('populate')
      end
    end
  end
end
