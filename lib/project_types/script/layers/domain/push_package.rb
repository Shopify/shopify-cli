# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id,
          :uuid,
          :extension_point_type,
          :script_name,
          :config_ui,
          :script_content,
          :compiled_type,
          :metadata

        def initialize(
          id:,
          uuid:,
          extension_point_type:,
          script_name:,
          script_content:,
          compiled_type:,
          metadata:,
          config_ui:
        )
          @id = id
          @uuid = uuid
          @extension_point_type = extension_point_type
          @script_name = script_name
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
          @config_ui = config_ui
        end

        def push(script_service, api_key, force)
          script_service.push(
            uuid: @uuid,
            extension_point_type: @extension_point_type,
            script_name: @script_name,
            script_content: @script_content,
            compiled_type: @compiled_type,
            api_key: api_key,
            force: force,
            metadata: @metadata,
            config_ui: @config_ui,
          )
        end
      end
    end
  end
end
