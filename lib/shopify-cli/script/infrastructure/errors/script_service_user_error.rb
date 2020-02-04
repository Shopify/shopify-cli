# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptServiceUserError < StandardError
        def initialize(query_name, errors, variables)
          super("Failed performing #{query_name}. Errors: #{errors}. Variables: #{variables}.")
        end
      end
    end
  end
end
