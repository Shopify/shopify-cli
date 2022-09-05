# frozen_string_literal: true
require "forwardable"
require "shopify_cli/theme/root"

module ShopifyCLI
  module Theme
    module Extension
      class AppExtension
        extend Forwardable

        attr_reader :app_id, :location, :registration_id
        def_delegators :@root_obj,
          :root,
          :static_asset_files,
          :liquid_files,
          :json_files,
          :glob,
          :static_asset_file?,
          :static_asset_paths,
          :[],
          :file?

        def initialize(ctx, root:, app_id: nil, location: nil, registration_id: nil)
          @app_id = app_id
          @location = location
          @registration_id = registration_id
          @root_obj = Root.new(ctx, root: root)
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
end
