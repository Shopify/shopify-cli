# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphqlError < StandardError
        def initialize(query_name, errors, variables)
          super("GraphQL errors in #{query_name}, with variables: #{variables}. Errors: #{errors}")
        end
      end
    end
  end
end
