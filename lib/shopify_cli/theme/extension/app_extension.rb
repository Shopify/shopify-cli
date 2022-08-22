# frozen_string_literal: true
require "shopify_cli/theme/root"

module ShopifyCLI
  module Theme
    class AppExtension
      extend Forwardable

      attr_reader :root, :id
      def_delegators :@root, :[], :glob, :static_asset_files

      def initialize(ctx, root:, id:)
        @id = id
        @root = Root.new(ctx, root: root)
      end

      def extension_files
        (glob(["**/*.liquid", "**/*.json"]) + static_asset_files).uniq
      end

      def extension_file?(file)
        extension_files.include?(self[file])
      end
    end
  end
end
