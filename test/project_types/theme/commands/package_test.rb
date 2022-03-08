# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PackageTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        @context.stubs(:which).with("zip").returns(true)
      end

      def test_package_theme
        theme_root = File.join(ShopifyCLI::ROOT, "test/fixtures/theme")
        @context.expects(:system).with(
          "zip",
          "-r",
          "Example-1.0.0.zip",
          *%w[
            assets
            config
            layout
            locales
            sections
            snippets
            templates
            release-notes.md
          ],
          chdir: theme_root
        )

        run_cmd("theme package #{theme_root}")
      end

      def test_invalid_theme
        theme_root = "."
        @context.expects(:system).never

        assert_raises(CLI::Kit::Abort) do
          run_cmd("theme package #{theme_root}")
        end
      end
    end
  end
end
