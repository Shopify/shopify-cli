# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ExtensionPoint
        attr_reader :type, :schema, :sdk_types, :example_script

        def initialize(type, schema, sdk_types, example_script)
          @type = type
          @schema = schema
          @sdk_types = sdk_types
          @example_script = example_script
        end
      end
    end
  end
end
