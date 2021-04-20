# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakePushPackageRepository
        def initialize
          @cache = {}
        end

        def create_push_package(
          script_project:,
          script_content:,
          compiled_type:,
          metadata:,
          config_ui:
        )
          id = id(script_project.script_name, compiled_type)
          @cache[id] = Domain::PushPackage.new(
            id: id,
            extension_point_type: script_project.extension_point_type,
            script_name: script_project.script_name,
            script_content: script_content,
            compiled_type: compiled_type,
            metadata: metadata,
            config_ui: config_ui,
          )
        end

        def get_push_package(script_project:, compiled_type:, metadata:, config_ui:)
          _ = metadata, config_ui
          id = id(script_project.script_name, compiled_type)
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
