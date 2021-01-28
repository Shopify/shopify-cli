# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id, :extension_point_type, :script_project, :script_content, :compiled_type, :metadata

        def initialize(id:, extension_point_type:, script_name:, script_content:, compiled_type:, metadata:)
          @id = id
          @extension_point_type = extension_point_type
          @script_name = script_name
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
        end

        def push(script_service, api_key, force)
          script_service.push(
            extension_point_type: @extension_point_type,
            script_name: @script_name,
            script_content: @script_content,
            compiled_type: @compiled_type,
            api_key: api_key,
            force: force,
            metadata: @metadata,
          )
        end
      end
    end
  end
end
