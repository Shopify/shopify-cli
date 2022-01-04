# typed: ignore
# frozen_string_literal: true
require "project_types/theme/test_helper"
require "theme_check"

module Theme
  module Commands
    class CheckTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_command_runs_theme_check
        context = ShopifyCLI::Context.new
        ThemeCheck::Cli.any_instance.expects(:run)

        Theme::Command::Check.new(context).call([])
      end

      def test_parse_options
        context = ShopifyCLI::Context.new
        ThemeCheck::Cli.any_instance.expects(:parse).with(["-l"])

        command = Theme::Command::Check.new(context)
        command.options.parse(nil, ["-l"])
      end
    end
  end
end
