# frozen_string_literal: true
require_relative "root"

module ShopifyCLI
  module Theme
    class AppExtension < Root
      attr_reader :root, :id

      def initialize(ctx, root:, id:)
        super(ctx, root: root)
        @id = id
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
