# frozen_string_literal: true

module Script
  module Layers
    module Application
      class ExtensionPoints
        def self.get(type:)
          Infrastructure::ExtensionPointRepository.new.get_extension_point(type)
        end

        def self.types
          Infrastructure::ExtensionPointRepository.new.extension_point_types
        end

        def self.non_deprecated_types
          Infrastructure::ExtensionPointRepository.new.extension_points.select do |ep|
            !ep.deprecated?
          end.map(&:type)
        end

        def self.deprecated_types
          Infrastructure::ExtensionPointRepository.new
            .extension_points
            .select(&:deprecated?)
            .map(&:type)
        end
      end
    end
  end
end
