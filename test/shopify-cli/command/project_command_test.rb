require "test_helper"

module ShopifyCLI
  class Command
    class FakeVisibleSubCommand < ShopifyCLI::Command::SubCommand; end

    class FakeHiddenSubCommand < ShopifyCLI::Command::SubCommand
      hidden_feature
    end

    class FakeCommand < ShopifyCLI::Command::ProjectCommand
      subcommand :FakeVisibleSubCommand, "fake_visible"
      subcommand :FakeHiddenSubCommand, "fake_hidden"

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

    class ProjectCommandTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Commands.register("ShopifyCLI::Command::FakeCommand", "fake")
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
