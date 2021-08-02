# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutUiExtension < Default
        PERMITTED_CONFIG_KEYS = [:metafields, :extension_points]

        def config(context)
          {
            **Features::ArgoConfig.parse_yaml(context, PERMITTED_CONFIG_KEYS),
            **argo.config(context),
          }
        end

        def supplies_resource_url?
          true
        end

        def build_resource_url(context:, shop:)
          variant_id = Tasks::GetProduct.call(context, shop).variant_id
          quantity = 1
          format("/cart/%d:%d", variant_id, quantity)
        end
      end
    end
  end
end
