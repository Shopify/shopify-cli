# typed: ignore
require "test_helper"

module ShopifyCLI
  class Command
    class ProjectCommandTest < MiniTest::Test
      class FakeVisibleSubCommand < ShopifyCLI::Command::SubCommand; end

      class FakeHiddenSubCommand < ShopifyCLI::Command::SubCommand
        hidden_feature
      end

      class FakeCommand < ShopifyCLI::Command::ProjectCommand
        subcommand FakeVisibleSubCommand.inspect, "fake_visible"
        subcommand FakeHiddenSubCommand.inspect, "fake_hidden"

        def self.name
          "fake"
        end

        def self.messages
          {
            fake: {
              help: "Usage: {{command:%1$s fake [ %2$s ]}}",
            },
          }
        end
      end

      def setup
        super
        ShopifyCLI::Commands.register(FakeCommand.inspect, "fake")
        ShopifyCLI::Context.load_messages(FakeCommand.messages)
      end

      def test_help_only_displays_visible_subcommands
        io = capture_io do
          run_cmd("help fake")
        end
        output = io.join

        assert_includes(output, "fake [ fake_visible ]")
        refute_includes(output, "fake_hidden")
      end
    end
  end
end
