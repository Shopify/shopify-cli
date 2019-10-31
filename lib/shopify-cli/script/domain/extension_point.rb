# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ExtensionPoint
        attr_reader :type, :schema, :sdk_types, :example_scripts

        def initialize(type, schema, sdk_types, example_script)
          @type = type
          @schema = schema
          @sdk_types = sdk_types
          # Will replace this once I change api on script service to return js stuff
          @example_scripts = {
            "ts" => example_script,
            "js" => nil,
            "json" => nil,
          }
        end
      end
    end
  end
end
