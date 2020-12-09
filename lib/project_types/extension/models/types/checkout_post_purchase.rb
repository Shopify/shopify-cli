# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class CheckoutPostPurchase < Models::Type
        IDENTIFIER = 'CHECKOUT_POST_PURCHASE'
        PERMITTED_CONFIG_KEYS = %i[metafields]
        def create(directory_name, context)
          Features::Argo::Checkout.new.create(directory_name, IDENTIFIER, context)
        end

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **Features::Argo::Checkout.new.config(context)
          }
        end
      end
    end
  end
end
