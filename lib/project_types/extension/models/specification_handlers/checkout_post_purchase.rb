# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutPostPurchase < Default
        PERMITTED_CONFIG_KEYS = [:metafields]

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
