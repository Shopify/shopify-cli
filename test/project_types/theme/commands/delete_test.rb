# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class DeleteTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCLI::Context.new
        @command = Theme::Command::Delete.new(@ctx)

        @config = mock("Config")
        @theme = stub(
          "Theme",
          id: 1234,
          name: "Test theme",
          shop: "test.myshopify.io",
          preview_url: "https://test.myshopify.io/",
          editor_url: "https://test.myshopify.io/",
          live?: false,
        )
      end

      def test_delete_with_invalid_theme_id
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: 1234)
          .returns(nil)

        @theme.expects(:delete).never
        @ctx.expects(:done).never
        @ctx.expects(:abort)
          .with(@ctx.message("theme.delete.theme_not_found", 1234))

        @command.options.flags[:theme] = 1234
        @command.call([], "delete")
      end

      def test_delete_with_valid_theme_name
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: "test_theme")
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.options.flags[:theme] = "test_theme"
        @command.call([], "delete")
      end

      def test_delete_with_invalid_theme_name
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: "test_theme")
          .returns(nil)

        @theme.expects(:delete).never
        @ctx.expects(:done).never
        @ctx.expects(:abort)
          .with(@ctx.message("theme.delete.theme_not_found", "test_theme"))

        @command.options.flags[:theme] = "test_theme"
        @command.call([], "delete")
      end

      def test_delete_with_valid_theme_id
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.call([], "delete")
      end

      def test_delete_unexisting_theme_ids
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete).raises(ShopifyCLI::API::APIRequestNotFoundError)
        @ctx.expects(:puts)
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.call([], "delete")
      end

      def test_cant_delete_live_theme
        ShopifyCLI::Theme::Theme.expects(:find_by_identifier)
          .with(@ctx, identifier: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)
        @ctx.expects(:puts)
        @theme.expects(:delete).never
        @ctx.expects(:done)

        @command.options.flags[:theme] = 1234
        @command.call([], "delete")
      end

      def test_delete_when_development_theme_exists
        ShopifyCLI::Theme::DevelopmentTheme.expects(:find)
          .with(@ctx)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.options.flags[:development] = true
        @command.call([], "delete")
      end

      def test_delete_when_development_theme_doesnt_exist
        ShopifyCLI::Theme::DevelopmentTheme.expects(:find)
          .with(@ctx)
          .returns(nil)

        @theme.expects(:delete).never
        @ctx.expects(:done).never
        @ctx.expects(:abort)
          .with(@ctx.message("theme.delete.no_development_theme_error"),
            @ctx.message("theme.delete.no_development_theme_resolution"))

        @command.options.flags[:development] = true
        @command.call([], "delete")
      end

      def test_delete_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.call([], "delete")
      end

      def test_delete_select_aborting
        CLI::UI::Prompt.expects(:ask).raises(ShopifyCLI::Abort)
        @ctx.expects(:puts)

        @theme.expects(:delete).never

        @command.call([], "delete")
      end

      def test_delete_asks_to_confirm
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        CLI::UI::Prompt.expects(:confirm).returns(false)

        @theme.expects(:delete).never
        @ctx.expects(:done)

        @command.call([], "delete")
      end

      def test_delete_force_with_option
        CLI::UI::Prompt.expects(:ask).returns(@theme)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.options.flags[:force] = true
        @command.call([], "delete")
      end

      def test_delete_when_no_valid_themes_to_select_from
        CLI::UI::Prompt.expects(:ask).raises(ShopifyCLI::Abort)

        @theme.expects(:delete).never
        @ctx.expects(:done).never
        @ctx.expects(:puts)

        @command.call([], "delete")
      end
    end
  end
end
