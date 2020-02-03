# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphqlError < StandardError
        def initialize(from, query_name, errors, variables)
          super("GraphQL errors in #{query_name} from #{from}. Errors: #{errors}. Variables: #{variables}.")
        end
      end
    end
  end
end
