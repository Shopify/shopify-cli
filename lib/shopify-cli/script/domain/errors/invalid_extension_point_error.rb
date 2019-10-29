# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class InvalidExtensionPointError < StandardError
        def initialize(type:)
          super("Extension point #{type} cannot be found")
        end
      end
    end
  end
end
