# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id, :script, :script_content, :compiled_type, :schema_major_version, :schema_minor_version

        def initialize(id, script, script_content, compiled_type, schema_major_version, schema_minor_version)
          @id = id
          @script = script
          @script_content = script_content
          @compiled_type = compiled_type
          @schema_major_version = schema_major_version
          @schema_minor_version = schema_minor_version
        end

        def push(script_service, api_key, force)
          script_service.push(
            extension_point_type: @script.extension_point_type,
            script_name: @script.name,
            script_content: @script_content,
            compiled_type: @compiled_type,
            api_key: api_key,
            force: force,
            schema_major_version: @schema_major_version,
            schema_minor_version: @schema_minor_version,
          )
        end
      end
    end
  end
end
