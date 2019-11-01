# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class DeployPackage
        attr_reader :id, :script, :script_content, :content_type, :schema

        def initialize(id, script, script_content, content_type, schema)
          @id = id
          @script = script
          @script_content = script_content
          @content_type = content_type
          @schema = schema
        end

        def deploy(script_service, app_key)
          script_service.deploy(
            extension_point_type: @script.extension_point.type,
            script_name: @script.name,
            script_content: @script_content,
            content_type: @content_type,
            schema: schema,
            app_key: app_key
          )
        end
      end
    end
  end
end
