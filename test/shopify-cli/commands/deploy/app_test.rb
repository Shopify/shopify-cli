require 'test_helper'

module ShopifyCli
  module Commands
    require 'shopify-cli/commands/deploy/app'
    class Deploy
      class AppTest < MiniTest::Test
        def setup
          super
          @cmd = ShopifyCli::Commands::Deploy::App
          @cmd.ctx = @context
          @cmd_name = 'deploy'
        end

        def test_heroku_subcommand_calls_heroku
          Deploy::App::Heroku.expects(:call)
          @cmd.call(['heroku'], @cmd_name)
        end

        def test_without_arguments_calls_help
          @context.expects(:puts).with(ShopifyCli::Commands::Deploy::App.help)
          @cmd.call([], @cmd_name)
        end
      end
    end
  end
end
