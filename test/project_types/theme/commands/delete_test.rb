# typed: ignore
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

      def test_delete_theme_ids
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

        @command.call([1234], "delete")
      end

      def test_delete_unexisting_theme_ids
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete).raises(ShopifyCLI::API::APIRequestNotFoundError)
        @ctx.expects(:puts)
        @ctx.expects(:done)

        @command.call([1234], "delete")
      end

      def test_cant_delete_live_theme
        ShopifyCLI::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        @theme.expects(:live?).returns(true)
        @ctx.expects(:puts)
        @theme.expects(:delete).never
        @ctx.expects(:done)

        @command.call([1234], "delete")
      end

      def test_delete_development_theme
        ShopifyCLI::Theme::DevelopmentTheme.expects(:new)
          .with(@ctx)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:delete)
        @ctx.expects(:done)

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
    end
  end
end
