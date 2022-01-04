# typed: ignore
# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutUiExtension < Default
        PERMITTED_CONFIG_KEYS = [:extension_points, :metafields, :name]

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context, include_renderer_version: false),
          }
        end

        def supplies_resource_url?
          true
        end

        def build_resource_url(context:, shop:)
          product = Tasks::GetProduct.call(context, shop)
          return unless product
          format("/cart/%<variant_id>d:%<quantity>d", variant_id: product.variant_id, quantity: 1)
        end
      end
    end
  end
end
