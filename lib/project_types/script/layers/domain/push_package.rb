# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id, :script, :script_content, :compiled_type, :metadata

        def initialize(id, script, script_content, compiled_type, metadata)
          @id = id
          @script = script
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
        end

        def push(script_service, api_key, force)
          script_service.push(
            extension_point_type: @script.extension_point_type,
            script_name: @script.name,
            script_content: @script_content,
            compiled_type: @compiled_type,
            api_key: api_key,
            force: force,
            schema_major_version: @metadata.schema_major_version,
            schema_minor_version: @metadata.schema_minor_version,
          )
        end
      end
    end
  end
end
