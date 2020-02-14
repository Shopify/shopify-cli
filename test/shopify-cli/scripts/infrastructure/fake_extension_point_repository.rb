# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class FakeExtensionPointRepository
        def initialize
          @cache = {}
        end

        def create_extension_point(type)
          add(ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(type, "schema", "types", "example"))
        end

        def add(extension_point)
          @cache[extension_point.type] = extension_point
        end

        def get_extension_point(type)
          if @cache.key?(type)
            @cache[type]
          else
            raise Domain::InvalidExtensionPointError.new(type: type)
          end
        end
      end
    end
  end
end
