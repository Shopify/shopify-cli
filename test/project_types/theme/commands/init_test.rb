# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class InitTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCLI::Context.new
        @command = Theme::Command::Init.new(@ctx)
      end

      def test_clones_repo
        ShopifyCLI::Git.expects(:clone).with(Theme::Command::Init::DEFAULT_CLONE_URL, "repo-name")

        @command.call(["repo-name"], "init")
      end

      def test_ask_repo_name
        ShopifyCLI::Git.expects(:clone).with(Theme::Command::Init::DEFAULT_CLONE_URL, "repo-name")
        CLI::UI::Prompt.expects(:ask).returns("repo-name")

        @command.call([], "init")
      end

      def test_repo_url_in_options
        ShopifyCLI::Git.expects(:clone).with("CLONE_URL", "repo-name")

        @command.options.flags[:clone_url] = "CLONE_URL"
        @command.call(["repo-name"], "init")
      end
    end
  end
end
