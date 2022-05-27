# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServerTest < Minitest::Test
      def setup
        super
        @ctx = ShopifyCLI::Context.new
        @theme = stub(
          "Dev Server Testing",
          root: ".",
          id: 1234,
          name: "DevServer Test",
          shop: "test.myshopify.io",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          live?: false,
        )
        ShopifyCLI::Theme::DevServer.ctx = @ctx
      end

      def test_abort_when_invalid_theme
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(@ctx, root: @theme.root, identifier: @theme.id)
          .returns(nil)

        error = assert_raises CLI::Kit::Abort do
          simulate_server(@theme.root, @theme.id)
        end
        assert_equal("{{x}} Theme \"1234\" doesn't exist", error.message)
      end

      def test_works_with_valid_theme_id
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(@ctx, root: @theme.root, identifier: @theme.id)
          .returns(@theme)

        simulate_server(@theme.root, @theme.id)
      end

      def test_works_with_valid_theme_name
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier)
          .with(@ctx, root: @theme.root, identifier: @theme.name)
          .returns(@theme)

        simulate_server(@theme.root, @theme.name)
      end

      def test_finds_or_creates_a_dev_theme_when_no_theme_specified
        ShopifyCLI::Theme::Theme
          .expects(:find_by_identifier).never
        ShopifyCLI::Theme::DevelopmentTheme
          .expects(:find_or_create!)
          .with(@ctx, root: ".").once

        simulate_server
      end

      private

      def simulate_server(root = ".", identifier = nil)
        ShopifyCLI::Theme::DevServer
          .send(:find_theme, root, identifier)
      end
    end
  end
end
