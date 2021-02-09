# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutPostPurchase < Default
        IDENTIFIER = 'CHECKOUT_POST_PURCHASE'
        PERMITTED_CONFIG_KEYS = [:metafields]
        def create(directory_name, context)
          argo.create(directory_name, IDENTIFIER, context)
        end

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context),
          }
        end
      end
    end
  end
end
