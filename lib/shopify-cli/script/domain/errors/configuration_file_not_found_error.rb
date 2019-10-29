# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ConfigurationFileNotFoundError < StandardError
        def initialize(script_name, path)
          super("config.schema for script: #{script_name} not found under #{path}")
        end
      end
    end
  end
end
