# frozen_string_literal: true
require "base64"

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutPostPurchase < Default
        PERMITTED_CONFIG_KEYS = [:metafields]
        RENDERER_PACKAGE_NAME = "@shopify/post-purchase-ui-extensions"

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context, include_renderer_version: false),
          }
        end

        protected

        def argo
          Features::Argo.new(
            git_template: specification.features.argo.git_template,
            renderer_package_name: RENDERER_PACKAGE_NAME
          )
        end
      end
    end
  end
end
