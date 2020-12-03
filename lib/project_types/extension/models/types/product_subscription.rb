# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class ProductSubscription < Models::Type
        IDENTIFIER = :subscription_management

        def cli_identifier
          :product_subscription
        end

        def template_identifier
          'PRODUCT_SUBSCRIPTION'
        end

        def create(directory_name, context)
          Features::Argo::Admin.new.create(directory_name, cli_identifier.to_s.upcase, context)
        end

        def config(context)
          Features::Argo::Admin.new.config(context)
        end
      end
    end
  end
end
