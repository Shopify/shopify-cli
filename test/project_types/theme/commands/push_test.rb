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

        @config = mock("Config")
        @theme = mock(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
          preview_url: "https://test.myshopify.io/",
          editor_url: "https://test.myshopify.io/",
        )
        @uploader = mock("Uploader")

        @uploader.expects(:start_threads)
        @uploader.expects(:shutdown)
        @ctx.expects(:done)
      end

      def test_push_to_theme_id
        ShopifyCli::Theme::Config.expects(:from_path)
          .returns(@config)

        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, @config, id: 1234)
          .returns(@theme)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, @theme)
          .returns(@uploader)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        @command.options.flags[:theme_id] = 1234
        @command.call([], "push")
      end

      def test_push_to_development_theme
        ShopifyCli::Theme::Config.expects(:from_path)
          .returns(@config)

        ShopifyCli::Theme::DevelopmentTheme.expects(:new)
          .with(@ctx, @config)
          .returns(@theme)

        @theme.expects(:ensure_exists!)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, @theme)
          .returns(@uploader)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        @command.options.flags[:development] = true
        @command.call([], "push")
      end

      def test_push_pass_nodelete_to_uploader
        ShopifyCli::Theme::Config.expects(:from_path)
          .returns(@config)

        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, @config, id: 1234)
          .returns(@theme)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, @theme)
          .returns(@uploader)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: false)

        @command.options.flags[:theme_id] = 1234
        @command.options.flags[:nodelete] = true
        @command.call([], "push")
      end

      def test_push_asks_to_select
        ShopifyCli::Theme::Config.expects(:from_path)
          .returns(@config)

        CLI::UI::Prompt.expects(:ask).returns(@theme)

        @uploader.expects(:upload_theme_with_progress_bar!).with(delete: true)

        ShopifyCli::Theme::Uploader.expects(:new)
          .with(@ctx, @theme)
          .returns(@uploader)

        @command.call([], "push")
      end
    end
  end
end
