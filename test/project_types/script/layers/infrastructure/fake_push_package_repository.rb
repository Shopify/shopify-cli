# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakePushPackageRepository
        def initialize
          @cache = {}
        end

        def create_push_package(script, script_content, compiled_type, metadata)
          id = id(script.name, compiled_type)
          @cache[id] = Domain::PushPackage.new(
            script.id,
            script,
            script_content,
            compiled_type,
            metadata,
          )
        end

        def get_push_package(script, compiled_type, _)
          id = id(script.name, compiled_type)
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
