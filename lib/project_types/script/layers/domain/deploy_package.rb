# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class DeployPackage
        attr_reader :id, :script, :script_content, :compiled_type, :schema

        def initialize(id, script, script_content, compiled_type, schema)
          @id = id
          @script = script
          @script_content = script_content
          @compiled_type = compiled_type
          @schema = schema
        end

        def deploy(script_service, api_key, force)
          script_service.deploy(
            extension_point_type: @script.extension_point_type,
            script_name: @script.name,
            script_content: @script_content,
            compiled_type: @compiled_type,
            schema: schema,
            api_key: api_key,
            force: force
          )
        end
      end
    end
  end
end
