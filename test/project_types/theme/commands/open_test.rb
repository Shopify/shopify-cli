# frozen_string_literal: true

require "project_types/theme/test_helper"

module Theme
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        @command = Theme::Command::Open.new(ctx)
      end

      def test_open_without_flags
        CLI::UI::Prompt.expects(:ask).returns(theme)

        ctx.expects(:open_browser_url!).with("https://test.myshopify.io/preview")

        io = capture_io do
          @command.call([], "open")
        end

        assert_message_output(io: io, expected_content: [
          "{{*}} {{bold:My test theme}}",

          "\n\nPreview your theme:",
          "{{green:https://test.myshopify.io/preview}}",

          "\n\nCustomize your theme in the Theme Editor:",
          "{{green:https://test.myshopify.io/editor}}",
        ])
      end

      def test_open_with_theme_flag
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(ctx, identifier: 1234)
          .returns(theme)

        ctx.expects(:open_browser_url!).with("https://test.myshopify.io/preview")

        io = capture_io do
          @command.options.flags[:theme] = 1234
          @command.call([], "open")
        end

        assert_message_output(io: io, expected_content: [
          "{{*}} {{bold:My test theme}}",

          "\n\nPreview your theme:",
          "{{green:https://test.myshopify.io/preview}}",

          "\n\nCustomize your theme in the Theme Editor:",
          "{{green:https://test.myshopify.io/editor}}",
        ])
      end

      def test_open_with_theme_flag_when_theme_does_not_exist
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(ctx, identifier: 1234)
          .returns(nil)

        ctx.expects(:open_browser_url!).never

        error = assert_raises CLI::Kit::Abort do
          @command.options.flags[:theme] = 1234
          @command.call([], "open")
        end

        assert_equal("{{x}} Theme \"1234\" doesn't exist", error.message)
      end

      def test_open_with_live_flag
        ShopifyCLI::Theme::Theme
          .expects(:live)
          .with(ctx)
          .returns(theme)

        ctx.expects(:open_browser_url!).with("https://test.myshopify.io/preview")

        io = capture_io do
          @command.options.flags[:live] = true
          @command.call([], "open")
        end

        assert_message_output(io: io, expected_content: [
          "{{*}} {{bold:My test theme}}",

          "\n\nPreview your theme:",
          "{{green:https://test.myshopify.io/preview}}",

          "\n\nCustomize your theme in the Theme Editor:",
          "{{green:https://test.myshopify.io/editor}}",
        ])
      end

      def test_open_with_development_flag
        ShopifyCLI::Theme::DevelopmentTheme
          .expects(:find)
          .with(ctx)
          .returns(theme)

        ctx.expects(:open_browser_url!).with("https://test.myshopify.io/preview")

        io = capture_io do
          @command.options.flags[:development] = true
          @command.call([], "open")
        end

        assert_message_output(io: io, expected_content: [
          "{{*}} {{bold:My test theme}}",

          "\n\nPreview your theme:",
          "{{green:https://test.myshopify.io/preview}}",

          "\n\nCustomize your theme in the Theme Editor:",
          "{{green:https://test.myshopify.io/editor}}",
        ])
      end

      def test_open_with_development_flag_when_theme_does_not_exist
        ShopifyCLI::Theme::DevelopmentTheme
          .expects(:find)
          .with(ctx)
          .returns(nil)

        error = assert_raises CLI::Kit::Abort do
          @command.options.flags[:development] = true
          @command.call([], "open")
        end

        assert_equal("{{x}} Theme \"development\" doesn't exist", error.message)
      end

      private

      def theme
        @theme ||= stub(
          "Theme",
          id: 1234,
          name: "My test theme",
          shop: "test.myshopify.io",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          live?: false,
        )
      end

      def ctx
        @ctx ||= ShopifyCLI::Context.new
      end
    end
  end
end
