# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PushTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCLI::Context.new
        @command = Theme::Command::Push.new(@ctx)

        @theme = stub(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
          preview_url: "https://test.myshopify.io/",
          editor_url: "https://test.myshopify.io/",
          live?: false,
        )
        @syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil, has_any_error?: false)
        @ignore_filter = mock("IgnoreFilter")
        @include_filter = mock("IncludeFilter")

        ShopifyCLI::Theme::IgnoreFilter.stubs(:from_path).with(".").returns(@ignore_filter)
        ShopifyCLI::Theme::IncludeFilter.stubs(:new).returns(@include_filter)
      end

      def test_push_with_deprecated_theme_id
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:warn)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.call([], "push")
      end

      def test_push_with_theme_id
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.call([], "push")
      end

      def test_push_with_theme_name
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: "Test theme")
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = "Test theme"
        @command.call([], "push")
      end

      def test_push_to_live
        ShopifyCLI::Theme::Theme.expects(:live)
          .with(@ctx, root: ".")
          .returns(@theme)

        @theme.expects(:live?).returns(true)
        CLI::UI::Prompt
          .expects(:confirm)
          .with("Are you sure you want to push to your live theme?\n  " \
                "Theme: {{blue:Test theme #1234}} {{green:[live]}}")
          .returns(true)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:live] = true
        @command.call([], "push")
      end

      def test_push_to_live_theme
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)

        CLI::UI::Prompt
          .expects(:confirm)
          .with("Are you sure you want to push to your live theme?")
          .returns(true)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.call([], "push")
      end

      def test_allow_live
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)

        CLI::UI::Prompt.expects(:confirm).never

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.options.flags[:allow_live] = true
        @command.call([], "push")
      end

      def test_push_json
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        @theme.expects(:to_h).returns({})

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @command.expects(:puts).with("{\"theme\":{}}")

        @ctx.expects(:puts).never

        @command.options.flags[:theme] = 1234
        @command.options.flags[:json] = 1234
        @command.call([], "push")
      end

      def test_push_when_syncer_has_an_error
        syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil, has_any_error?: true)

        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        @theme.expects(:to_h).returns({})

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(syncer)

        syncer.expects(:start_threads)
        syncer.expects(:shutdown)

        syncer.expects(:upload_theme!).with(delete: true)
        @command.expects(:puts).with("{\"theme\":{}}")

        @ctx.expects(:puts).never

        @command.options.flags[:theme] = 1234
        @command.options.flags[:json] = 1234

        assert_raises(ShopifyCLI::AbortSilent) do
          @command.call([], "push")
        end
      end

      def test_push_and_publish
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)
        @theme.expects(:publish)

        @command.options.flags[:theme] = 1234
        @command.options.flags[:publish] = true
        @command.call([], "push")
      end

      def test_push_with_filter
        includes = ["config/*"]
        include_filter = mock("IncludeFilter")

        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)
        ShopifyCLI::Theme::IncludeFilter.expects(:new)
          .with(includes)
          .returns(include_filter)
        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.options.flags[:includes] = includes
        @command.call([], "push")
      end

      def test_push_with_ignores
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)
        @ignore_filter.expects(:add_patterns).with(["config/*"])

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.options.flags[:ignores] = ["config/*"]
        @command.call([], "push")
      end

      def test_push_to_development_theme
        ShopifyCLI::Theme::DevelopmentTheme.expects(:find_or_create!)
          .with(@ctx, root: ".")
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:development] = true
        @command.call([], "push")
      end

      def test_push_to_unpublished_theme
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", name: "NAME", role: "unpublished")
          .returns(@theme)

        CLI::UI::Prompt.expects(:ask).returns("NAME")

        @theme.expects(:create)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:unpublished] = true
        @command.call([], "push")
      end

      def test_push_to_unpublished_theme_when_name_is_provided
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", name: "NAME", role: "unpublished")
          .returns(@theme)

        CLI::UI::Prompt.expects(:ask).never

        @theme.expects(:create)

        ShopifyCLI::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:unpublished] = true
        @command.options.flags[:theme] = "NAME"
        @command.call([], "push")
      end

      def test_push_pass_nodelete_to_syncer
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, root: ".", identifier: 1234)
          .returns(@theme)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @syncer.expects(:upload_theme!).with(delete: false)

        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.options.flags[:nodelete] = true
        @command.call([], "push")
      end

      def test_push_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        @ctx.expects(:done)

        @syncer.expects(:upload_theme!).with(delete: true)

        ShopifyCLI::Theme::Syncer.expects(:new)
          .with(@ctx, theme: @theme, include_filter: @include_filter, ignore_filter: @ignore_filter)
          .returns(@syncer)

        @syncer.expects(:start_threads)
        @syncer.expects(:shutdown)

        @command.call([], "push")
      end

      def test_push_select_aborting
        CLI::UI::Prompt.expects(:ask).raises(ShopifyCLI::Abort)
        @ctx.expects(:puts)

        ShopifyCLI::Theme::Syncer.expects(:new).never

        @command.call([], "push")
      end
    end
  end
end
