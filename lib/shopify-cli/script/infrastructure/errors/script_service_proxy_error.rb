# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptServiceProxyError < GraphqlError
        def initialize(query_name, errors, variables)
          super(query_name, errors, variables)
        end
      end
    end
  end
end
