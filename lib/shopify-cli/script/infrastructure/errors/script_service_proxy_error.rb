# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptServiceProxyError < GraphqlError
        def initialize(errors, variables)
          super("script_service_proxy", errors, variables)
        end
      end
    end
  end
end
