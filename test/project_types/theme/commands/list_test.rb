# frozen_string_literal: true

require "project_types/theme/test_helper"

module Theme
  module Commands
    class ListTest < MiniTest::Test
      def setup
        super
        @command = Theme::Command::List.new(ctx)
      end

      def test_list
        mock_admin_api_shop
        mock_themes_presenter

        io = capture_io do
          @command.call([], "list")
        end

        assert_message_output(io: io, expected_content: [
          "{{*}} List of {{bold:dev-theme-server-store.myshopify.com}} themes:",
          "  Theme 1",
          "  Theme 2",
          "  Theme 3",
        ])
      end

      private

      def mock_admin_api_shop
        shop = "dev-theme-server-store.myshopify.com"
        ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(shop)
      end

      def mock_themes_presenter
        Theme::Presenters::ThemesPresenter
          .expects(:new)
          .with(ctx, nil)
          .returns(themes_presenter)
      end

      def ctx
        @ctx ||= ShopifyCLI::Context.new
      end

      def themes_presenter
        stub(all: [
          stub(to_s: "Theme 1"),
          stub(to_s: "Theme 2"),
          stub(to_s: "Theme 3"),
        ])
      end
    end
  end
end
