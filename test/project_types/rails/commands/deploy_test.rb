require 'test_helper'

module Rails
  module Commands
    class DeployTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:rails)
        @command = Rails::Commands::Deploy.new(@context)
      end

      def test_heroku_subcommand_calls_heroku
        Rails::Commands::Deploy::Heroku.expects(:call)
        run_cmd('deploy heroku')
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Commands::Deploy.help)
        run_cmd('deploy')
      end

      def test_help_argument_calls_extended_help
        @context.expects(:puts).with(Rails::Commands::Deploy.help + "\n" + Rails::Commands::Deploy.extended_help)
        run_cmd('help deploy')
      end
    end
  end
end
