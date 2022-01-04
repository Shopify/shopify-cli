# typed: ignore
# frozen_string_literal: true
require "project_types/theme/test_helper"
require "theme_check"

module Theme
  module Commands
    class LanguageServerTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_command_runs_theme_check_lsp
        ThemeCheck::LanguageServer.expects(:start)

        run_cmd("theme language-server")
      end
    end
  end
end
