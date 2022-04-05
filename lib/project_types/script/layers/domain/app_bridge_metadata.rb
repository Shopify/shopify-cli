# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class AppBridgeMetadata
        attr_reader :configuration_details_path, :configuration_create_path

        def initialize(configuration_details_path:, configuration_create_path:)
          @configuration_details_path = configuration_details_path
          @configuration_create_path = configuration_create_path
        end
      end
    end
  end
end
