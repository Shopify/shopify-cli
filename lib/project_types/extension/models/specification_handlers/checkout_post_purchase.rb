# frozen_string_literal: true
require "base64"

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutPostPurchase < Argo
        PERMITTED_CONFIG_KEYS = [:metafields]
        CLI_PACKAGE_NAME = "@shopify/argo-run"

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
