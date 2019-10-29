# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class WasmNotFoundError < StandardError
        def initialize(extension_point_type, script_name)
          super("There is no wasm bytecode for extension point #{extension_point_type} script #{script_name}")
        end
      end
    end
  end
end
