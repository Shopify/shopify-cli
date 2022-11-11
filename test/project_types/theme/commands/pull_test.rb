# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PullTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::DB.stubs(:exists?).returns(true)
        ShopifyCLI::DB.stubs(:get).with(:shop).returns("test.myshopify.com")

        @ctx = ShopifyCLI::Context.new
        @root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @command = Theme::Command::Pull.new(@ctx)

        @theme = stub(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
        )
        @syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil, has_any_error?: false)
        @ignore_filter = mock("IgnoreFilter")
        @include_filter = mock("IncludeFilter")

        ShopifyCLI::Theme::IgnoreFilter.stubs(:from_path).with(".").returns(@ignore_filter)
        ShopifyCLI::Theme::IncludeFilter.stubs(:new).returns(@include_filter)
      end

      def test_pull_with_deprecated_theme_id
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: @root, id: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:warn)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme_id] = 1234
        @command.call([], "pull")
      end

      def test_pull_with_id
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: @root, identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme] = 1234
        @command.call([], "pull")
      end

      def test_pull_with_name
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: @root, identifier: "Test theme")
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme] = "Test theme"
        @command.call([], "pull")
      end

      def test_pull_with_empty_root
        specified_root = "dist"
        FileUtils.mkdir(specified_root)

        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: specified_root, identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(specified_root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([specified_root])

        @command.options.flags[:theme] = 1234
        @command.call([], "pull")
      ensure
        FileUtils.rmdir(specified_root)
      end

      def test_pull_live_theme
        ShopifyCLI::Theme::Theme.expects(:live)
          .with(@ctx, root: @root)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:live] = true
        @command.call([], "pull")
      end

      def test_pull_development_theme
        ShopifyCLI::Theme::DevelopmentTheme.expects(:find)
          .with(@ctx, root: @root)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:development] = true
        @command.call([], "pull")
      end

      def test_pull_development_theme_when_does_not_exist
        ShopifyCLI::Theme::DevelopmentTheme.expects(:find)
          .with(@ctx, root: @root)
          .returns(nil)

        @ctx.expects(:message)
          .with("theme.pull.theme_not_found", "development")

        @ctx.expects(:abort)

        stubs_command_parser([@root])

        @command.options.flags[:development] = true
        @command.call([], "pull")
      end

      def test_pull_pass_nodelete_to_syncer
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: @root, identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: false)

        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme] = 1234
        @command.options.flags[:nodelete] = true
        @command.call([], "pull")
      end

      def test_pull_with_filter
        includes = ["config/*"]
        include_filter = mock("IncludeFilter")

        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: @root, identifier: 1234)
          .returns(@theme)
        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)
        ShopifyCLI::Theme::IncludeFilter.expects(:new)
          .with(@root, includes)
          .returns(include_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)
        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme] = 1234
        @command.options.flags[:includes] = includes
        @command.call([], "pull")
      end

      def test_pull_with_ignores
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: @root, identifier: 1234)
          .returns(@theme)

        @ignore_filter.expects(:add_patterns).with(["config/*"])

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path)
          .with(@root)
          .returns(@ignore_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:download_theme!).with(delete: true)

        @ctx.expects(:done)

        stubs_command_parser([@root])

        @command.options.flags[:theme] = 1234
        @command.options.flags[:ignores] = ["config/*"]
        @command.call([], "pull")
      end

      def test_pull_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        @ctx.expects(:done)

        @syncer.expects(:download_theme!).with(delete: true)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        stubs_command_parser([@root])

        @command.call([], "pull")
      end

      def test_pull_with_asset_errors_displays_warning
        CLI::UI::Prompt.expects(:ask).with("Select a theme to pull from test.myshopify.com",
          allow_empty: false).returns(@theme)
        @ctx.expects(:warn).with(@ctx.message("theme.pull.done_with_errors")).once
        @ctx.expects(:done).never

        @syncer.expects(:download_theme!).with(delete: true)
        @syncer.stubs(:has_any_error?).returns(true)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(@root).returns(@ignore_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        stubs_command_parser([@root])

        @command.call([], "pull")
      end

      private

      def stubs_command_parser(argv)
        argv = ["shopify", "theme", "pull"] + argv
        parser = @command.options.parser
        parser.stubs(:default_argv).returns(argv)
      end
    end
  end
end
