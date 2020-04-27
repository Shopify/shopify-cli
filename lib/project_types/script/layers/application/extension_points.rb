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
      end
    end
  end
end
