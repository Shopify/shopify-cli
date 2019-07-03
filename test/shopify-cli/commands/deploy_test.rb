require 'test_helper'

module ShopifyCli
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Deploy.new(@context)
      end

      def test_heroku_subcommand_calls_heroku
        Deploy::Heroku.expects(:call)
        @command.call(['heroku'], nil)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Deploy.help)
        @command.call([], nil)
      end
    end
  end
end
