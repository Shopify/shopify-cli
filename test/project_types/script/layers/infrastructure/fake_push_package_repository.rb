# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakePushPackageRepository
        def initialize
          @cache = {}
        end

        def create_push_package(extension_point_type, script_name, script_content, compiled_type, metadata)
          id = id(script_name, compiled_type)
          @cache[id] = Domain::PushPackage.new(
            id: id,
            extension_point_type: extension_point_type,
            script_name: script_name,
            script_content: script_content,
            compiled_type: compiled_type,
            metadata: metadata
          )
        end

        def get_push_package(_, script_name, compiled_type, _)
          id = id(script_name, compiled_type)
          if @cache.key?(id)
            @cache[id]
          else
            raise Domain::Errors::PushPackageNotFoundError
          end
        end

        private

        def id(script_name, compiled_type)
          "#{script_name}.#{compiled_type}"
        end
      end
    end
  end
end
