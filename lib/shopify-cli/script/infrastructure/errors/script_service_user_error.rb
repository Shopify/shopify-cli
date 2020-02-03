# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptServiceUserError < GraphqlError
        def initialize(query_name, errors, variables)
          super('Script Service', query_name, errors, variables)
        end
      end
    end
  end
end
