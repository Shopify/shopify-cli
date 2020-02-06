require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      def setup
        super
        @cmd = ShopifyCli::Commands::Create
        @cmd.ctx = @context
        @cmd_name = 'create'
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Create.help)
        @cmd.call([], @cmd_name)
      end

      def test_with_create_app
        Create::App.any_instance.expects(:call)
          .with(['new-app'], 'app')
        @cmd.call(['app', 'new-app'], @cmd_name)
      end

      def test_with_create_script
        Create::Script.any_instance.expects(:call)
          .with(['discount', 'new-script'], 'script')
        @cmd.call(['script', 'discount', 'new-script'], @cmd_name)
      end
    end
  end
end
