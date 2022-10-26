# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PackageTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
      end

      def test_zip_and_seven_zip_command_present
        @context.stubs(:which).with("zip").returns("path/to/zip")
        @context.stubs(:which).with("7z").returns("path/to/7z")

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

      def test_only_seven_zip_command_present
        @context.stubs(:which).with("zip").returns(nil)
        @context.stubs(:which).with("7z").returns("path/to/7z")

        theme_root = File.join(ShopifyCLI::ROOT, "test/fixtures/theme")
        @context.expects(:system).with(
          "7z",
          "a",
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

      def test_only_zip_command_present
        @context.stubs(:which).with("zip").returns("path/to/zip")
        @context.stubs(:which).with("7z").returns(nil)

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

      def test_no_system_zip_command_present
        @context.stubs(:which).with("zip").returns(nil)
        @context.stubs(:which).with("7z").returns(nil)

        theme_root = File.join(ShopifyCLI::ROOT, "test/fixtures/theme")

        error = assert_raises(CLI::Kit::Abort) do
          run_cmd("theme package #{theme_root}")
        end

        assert_equal(
          "{{x}} zip or 7zip is required for packaging a theme. Please install "\
          "zip or 7zip using the appropriate package manager for your system.",
          error.message
        )
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
