# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id,
          :uuid,
          :extension_point_type,
          :script_json,
          :script_content,
          :compiled_type,
          :metadata

        def initialize(
          id:,
          uuid:,
          extension_point_type:,
          script_content:,
          compiled_type: nil,
          metadata:,
          script_json:
        )
          @id = id
          @uuid = uuid
          @extension_point_type = extension_point_type
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
          @script_json = script_json
        end

        def push(script_service, api_key, force)
          script_service.push(
            uuid: @uuid,
            extension_point_type: @extension_point_type,
            script_content: @script_content,
            api_key: api_key,
            force: force,
            metadata: @metadata,
            script_json: @script_json,
          )
        end
      end
    end
  end
end
