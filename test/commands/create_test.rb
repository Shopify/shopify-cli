require 'test_helper'

module ShopifyCli
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @command = ShopifyCli::Commands::Create.new(@context)
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

      def test_implemented_option
        FileUtils.mkdir_p('/test-app')
        CLI::UI::Prompt.expects(:ask).returns(:node)
        ShopifyCli::AppTypes::Node.any_instance.stubs(:call).with('test-app', @context)
        @command.call(['test-app'], nil)
      end
    end
  end
end
