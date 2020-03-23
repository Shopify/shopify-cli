require 'test_helper'

module ShopifyCli
  module Commands
    class DeployTest < MiniTest::Test
      def setup
        super
        @command = ShopifyCli::Commands::Deploy.new(@context)
      end

      def test_heroku_subcommand_calls_heroku
        Deploy::Heroku.expects(:call)
        run_cmd('deploy heroku')
      end

      def test_now_subcommand_calls_now
        Deploy::Now.expects(:call)
        @command.call(['now'], nil)
      end

      def test_now_subcommand_calls_now
        Deploy::Now.expects(:call)
        @command.call(['now'], nil)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Deploy.help)
        run_cmd('deploy')
      end
    end
  end
end
