require 'test_helper'

module Rails
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::Heroku

      def setup
        super
        ShopifyCli::Project.stubs(:current_project_type).returns(:rails)
        ShopifyCli::Context.any_instance.stubs(:os).returns(:mac)
        stub_successful_heroku_flow
        # @command = Rails::Commands::Deploy.new(@context)
      end

      def test_heroku_subcommand_calls_heroku
        Rails::Commands::Deploy::Heroku.expects(:call).returns(true)
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
