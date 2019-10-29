# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class DeployPackage
        attr_reader :id, :script, :bytecode

        def initialize(id, script, bytecode)
          @id = id
          @script = script
          @bytecode = bytecode
        end

        def deploy(script_service, shop_id, config_value)
          script_service.deploy(
            extension_point_type: @script.extension_point.type,
            extension_point_schema: @script.schema,
            script_name: @script.name,
            bytecode: @bytecode,
            config_schema: @script.configuration.schema,
            shop_id: shop_id,
            config_value: config_value
          )
        end
      end
    end
  end
end
