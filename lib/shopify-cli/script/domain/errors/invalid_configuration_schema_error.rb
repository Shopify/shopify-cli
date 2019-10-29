# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class InvalidConfigurationSchemaError < StandardError
        def initialize(message)
          super("Invalid configuration schema: #{message}")
        end
      end
    end
  end
end
