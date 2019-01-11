require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::Create.new
      end

      def test_prints_help_with_no_name_argument
        io = capture_io do
          @command.call([], nil)
        end

        assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create.help), io.join)
      end

      def test_exists_with_not_implemented_choice
        CLI::UI::Prompt.expects(:ask).returns(false)
        io = capture_io do
          @command.call(['test-app'], nil)
        end

        assert_match('not yet implemented', io.join)
      end

      def test_embedded_app_creation
        CLI::UI::Prompt.expects(:ask).returns('embedded_app')
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/webgen-embeddedapp.git',
          'test-app'
        )
        CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
        @command.expects(:write_env_file)
        @command.expects(:yarn)
        io = capture_io do
          @command.call(['test-app'], nil)
        end
        output = io.join

        assert_match('Installing dependencies...', output)
      end
    end
  end
end
