require 'test_helper'

module Node
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::Heroku
      
      def setup
        super
        ShopifyCli::Project.stubs(:current_project_type).returns(:node)
        ShopifyCli::Context.any_instance.stubs(:os).returns(:mac)
        stub_successful_heroku_flow
        # @command = Node::Commands::Deploy.new(@context)
      end

      def test_heroku_subcommand_calls_heroku
        Node::Commands::Deploy::Heroku.expects(:call).returns(true)
        run_cmd('deploy heroku')
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Node::Commands::Deploy.help)
        run_cmd('deploy')
      end

      def test_help_argument_calls_extended_help
        @context.expects(:puts).with(Node::Commands::Deploy.help + "\n" + Node::Commands::Deploy.extended_help)
        run_cmd('help deploy')
      end
    end
  end
end
