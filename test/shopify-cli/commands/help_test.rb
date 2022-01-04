# typed: ignore
require "test_helper"

module Rails
  module Commands
    class Fake < ShopifyCLI::Command
    end
  end
end

module ShopifyCLI
  module Commands
    class FakeCommand < ShopifyCLI::Command::ProjectCommand
    end

    class HelpTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Commands.register(:FakeCommand, "fake", "fake_path", true)
      end

      def test_default_behavior_lists_tasks
        io = capture_io do
          run_cmd("help")
        end
        output = io.join
        assert_match(/Use .*shopify help <command>.* to display detailed information about a specific command./, output)
        assert_match(/Usage: .*shopify/, output)
      end

      def test_extended_help_for_individual_command
        io = capture_io do
          run_cmd("help fake")
        end
        output = io.join
        assert_match("shopifycli.help", output)
      end
    end
  end
end
