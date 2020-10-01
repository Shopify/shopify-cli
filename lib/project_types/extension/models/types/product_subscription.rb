# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class ProductSubscription < Models::Type
        IDENTIFIER = 'PRODUCT_SUBSCRIPTION'

        def graphql_identifier
          'SUBSCRIPTION_MANAGEMENT'
        end

        def create(directory_name, context)
          Features::Argo::Admin.new.create(directory_name, graphql_identifier, context)
        end

        def config(context)
          Features::Argo::Admin.new.config(context)
        end
      end
    end
  end
end
