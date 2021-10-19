# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class ProductSubscription < Default
        def graphql_identifier
          "SUBSCRIPTION_MANAGEMENT"
        end
      end
    end
  end
end
