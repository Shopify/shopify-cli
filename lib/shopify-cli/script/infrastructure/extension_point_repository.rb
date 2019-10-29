# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ExtensionPointRepository < Repository
        def initialize(script_service)
          @script_service = script_service
        end

        def get_extension_point(type)
          schema, sdk_types, example = fetch_extension_point(type)
          ScriptModule::Domain::ExtensionPoint.new(type, schema, sdk_types, example)
        end

        private

        def fetch_extension_point(type)
          extension_point_attributes = @script_service
            .fetch_extension_points
            .select { |ep| ep["name"] == type }
            .map { |ep| [ep["schema"], ep["types"], ep["script_example"]] }
            .first

          raise Domain::InvalidExtensionPointError.new(type: type) unless extension_point_attributes&.all?
          extension_point_attributes
        end
      end
    end
  end
end
