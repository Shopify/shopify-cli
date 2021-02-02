# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module SpecificationHandlers
      class ProductSubscription < Default
        IDENTIFIER = 'PRODUCT_SUBSCRIPTION'

        def graphql_identifier
          'SUBSCRIPTION_MANAGEMENT'
        end

        def create(directory_name, context)
          Features::Argo::Admin.new.create(directory_name, IDENTIFIER, context)
        end

        def config(context)
          Features::Argo::Admin.new.config(context)
        end
      end
    end
  end
end
