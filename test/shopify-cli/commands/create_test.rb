require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        run_cmd('create')
      end

      def test_with_project_calls_project
        Create::Project.any_instance.expects(:call)
          .with(['new-app'], 'project')
        run_cmd('create project new-app')
      end
    end
  end
end
