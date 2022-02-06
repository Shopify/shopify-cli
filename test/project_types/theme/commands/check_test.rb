# frozen_string_literal: true
require "project_types/theme/test_helper"
require "theme_check"

module Theme
  module Commands
    class CheckTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_command_runs_theme_check
        context = ShopifyCLI::Context.new
        ThemeCheck::Cli.any_instance.expects(:run!)

        Theme::Command::Check.new(context).call([])
      end

      def test_parse_options
        context = ShopifyCLI::Context.new
        ThemeCheck::Cli.any_instance.expects(:parse).with(["-l"])

        command = Theme::Command::Check.new(context)
        command.options.parse(nil, ["-l"])
      end

      def test_command_runs_theme_check_and_handles_error
        context = ShopifyCLI::Context.new
        error = ThemeCheck::Cli::Abort.new("There was a problem!")
        ThemeCheck::Cli.any_instance.expects(:run!).raises(error)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          Theme::Command::Check.new(context).call([])
        end

        assert_message_output(io: io, expected_content: [
          ShopifyCLI::Context.message('theme.check.error', error.full_message)
        ])
      end
    end
  end
end
