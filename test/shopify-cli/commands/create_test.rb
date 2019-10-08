require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @command = ShopifyCli::Commands::Create
        @command.ctx = @context
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        @command.call([], nil)
      end

      def test_with_project_calls_project
        ShopifyCli::Commands::Create::Project.any_instance.expects(:call)
          .with(['new-app'], 'project')
        @command.call(['project', 'new-app'], nil)
      end
    end
  end
end
