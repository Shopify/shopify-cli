# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id,
          :extension_point_type,
          :script_name,
          :description,
          :configuration_ui_yaml,
          :script_content,
          :compiled_type,
          :metadata

        def initialize(
          id:,
          extension_point_type:,
          script_name:,
          description:,
          script_content:,
          compiled_type:,
          metadata:,
          configuration_ui_yaml:
        )
          @id = id
          @extension_point_type = extension_point_type
          @script_name = script_name
          @description = description
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
          @configuration_ui_yaml = configuration_ui_yaml
        end

        def push(script_service, api_key, force)
          script_service.push(
            extension_point_type: @extension_point_type,
            script_name: @script_name,
            description: @description,
            script_content: @script_content,
            compiled_type: @compiled_type,
            api_key: api_key,
            force: force,
            metadata: @metadata,
            configuration_ui_yaml: @configuration_ui_yaml,
          )
        end
      end
    end
  end
end
