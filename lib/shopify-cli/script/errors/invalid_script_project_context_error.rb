# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    class InvalidScriptProjectContextError < StandardError
      def initialize(missing_property)
        super("#{missing_property} was not found in .shopify-cli.yml")
      end
    end
  end
end
