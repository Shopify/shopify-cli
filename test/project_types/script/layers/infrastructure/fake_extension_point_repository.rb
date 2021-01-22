# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Layers
    module Infrastructure
      class FakeExtensionPointRepository
        def initialize
          @cache = {}
        end

        def create_extension_point(type)
          @cache[type] = Domain::ExtensionPoint.new(type, example_config(type))
        end

        def create_deprecated_extension_point(type)
          @cache[type] = Domain::ExtensionPoint.new(type, deprecated_config(type))
        end

        def get_extension_point(type)
          if @cache.key?(type)
            @cache[type]
          else
            raise Domain::Errors::InvalidExtensionPointError, type
          end
        end

        def extension_points
          @cache.values
        end

        def extension_point_types
          @cache.keys
        end

        private

        def deprecated_config(type)
          example_config(type).merge({ "deprecated" => true })
        end

        def example_config(type)
          {
            "assemblyscript" => {
              "package" => type,
              "version" => "1",
              "sdk" => "1",
            },
            "rust" => {
              "beta" => true,
              "package" => type,
              "version" => "1",
              "sdk" => "1",
            },
          }
        end
      end
    end
  end
end
