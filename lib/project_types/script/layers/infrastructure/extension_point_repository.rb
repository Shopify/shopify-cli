# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ExtensionPointRepository < Repository
        def get_extension_point(type)
          Domain::ExtensionPoint.new(type, fetch_extension_point(type))
        end

        def extension_point_types
          extension_points.keys
        end

        private

        def fetch_extension_point(type)
          raise Domain::InvalidExtensionPointError.new(type: type) unless extension_points[type]
          extension_points[type]
        end

        def extension_points
          @extension_points ||= begin
            require 'yaml'
            YAML.load_file(File.join(ShopifyCli::ROOT, 'config/extension_points.yml'))
          end
        end
      end
    end
  end
end
