# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutArgoExtension < Default
        PERMITTED_CONFIG_KEYS = [:metafields, :extension_points]

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
