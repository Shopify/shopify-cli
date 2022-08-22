# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/root"
require "project_types/extension/extension_test_helpers"

module ShopifyCLI
  module Theme
    class RootTest < Minitest::Test
      def setup
        @root = Root.new(ctx, root: root)
      end

      def test_thing
        # @root.glob("**/*.liquid")
      end

      private

      def root
        ShopifyCLI::ROOT
      end

      def ctx
        TestHelpers::FakeContext.new
      end
    end
  end
end
