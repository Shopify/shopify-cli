# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PushTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCli::Context.new
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
        @uploader = mock("Uploader")
        @ignore_filter = mock("IgnoreFilter")
      end

      def test_push_to_theme_id
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.call([], "push")
      end

      def test_push_to_live_theme
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.call([], "push")
      end

      def test_allow_live
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)

        CLI::UI::Prompt.expects(:confirm).never

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)
        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:allow_live] = true
        @command.call([], "push")
      end

      def test_push_json
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        @theme.expects(:to_h).returns({})

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme!).with(delete: true)
        @command.expects(:puts).with("{\"theme\":{}}")

        @ctx.expects(:puts).never

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:json] = 1234
        @command.call([], "push")
      end

      def test_push_and_publish
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)
        @ctx.expects(:done)
        @theme.expects(:publish)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:publish] = true
        @command.call([], "push")
      end

      def test_push_to_development_theme
        ShopifyCli::Theme::DevelopmentTheme.expects(:new)
          .with(@ctx, root: ".")
          .returns(@theme)

        @theme.expects(:ensure_exists!)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:development] = true
        @command.call([], "push")
      end

      def test_push_to_unpublished_theme
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", name: "NAME", role: "unpublished")
          .returns(@theme)

        CLI::UI::Prompt.expects(:ask).returns("NAME")

        @theme.expects(:create)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        @ctx.expects(:done)

        @command.options.flags[:unpublished] = true
        @command.call([], "push")
      end

      def test_push_pass_nodelete_to_uploader
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, root: ".", id: 1234)
          .returns(@theme)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: false)

        @ctx.expects(:done)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:nodelete] = true
        @command.call([], "push")
      end

      def test_push_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        @ctx.expects(:done)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        ShopifyCli::Theme::IgnoreFilter.expects(:from_path).with(".").returns(@ignore_filter)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, theme: @theme, ignore_filter: @ignore_filter)
          .returns(@uploader)

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)

        @command.call([], "push")
      end

      def test_push_select_aborting
        CLI::UI::Prompt.expects(:ask).raises(ShopifyCli::Abort)
        @ctx.expects(:puts)

        ShopifyCli::Theme::Uploader.expects(:new).never

        @command.call([], "push")
      end
    end
  end
end
