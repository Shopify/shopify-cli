# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class PublishTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super

        @ctx = ShopifyCli::Context.new
        @command = Theme::Command::Publish.new(@ctx)

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

      def test_publish
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:publish)
        @ctx.expects(:done)

        @command.call([@theme.id])
      end

      def test_publish_without_confirmation
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        CLI::UI::Prompt.expects(:confirm).returns(false)

        @theme.expects(:publish).never

        @command.call([@theme.id])
      end

      def test_publish_force_with_option
        ShopifyCli::Theme::Theme.expects(:new)
          .with(@ctx, id: 1234)
          .returns(@theme)

        @theme.expects(:publish)
        @ctx.expects(:done)

        @command.options.flags[:force] = true
        @command.call([@theme.id])
      end

      def test_publish_asks_to_select
        CLI::UI::Prompt.expects(:ask).returns(@theme)
        CLI::UI::Prompt.expects(:confirm).returns(true)

        @theme.expects(:publish)
        @ctx.expects(:done)

        @command.call([])
      end
    end
  end
end
