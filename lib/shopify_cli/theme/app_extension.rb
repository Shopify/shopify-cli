# frozen_string_literal: true
require_relative "root"

module ShopifyCLI
  module Theme
    class AppExtension < Root
      attr_reader :root, :location, :registration_id

      def initialize(ctx, root:, location: nil, registration_id: nil)
        super(ctx, root: root)

        @location = location
        @registration_id = registration_id
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
