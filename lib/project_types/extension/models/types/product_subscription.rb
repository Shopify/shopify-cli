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
          # I know using a different string for the identifier here is gross.
          # I needed a quick way to rename this extension without breaking the partners mutation.
          Features::Argo.admin.create(directory_name, graphql_identifier, context)
        end

        def config(context)
          Features::Argo.admin.config(context)
        end
      end
    end
  end
end
