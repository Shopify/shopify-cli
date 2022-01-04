# typed: ignore
# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module FetchSpecifications
        include TestHelpers::Partners

        def stub_fetch_specifications(api_key:, specification_attributes: nil)
          if specification_attributes && !specification_attributes.is_a?(Array)
            raise ArgumentError, "Expected specification attributes to be an array"
          end

          stub_partner_req(
            "fetch_specifications",
            variables: {
              api_key: api_key,
            },
            resp: {
              data: {
                extensionSpecifications: specification_attributes || create_fake_specifications,
              },
            },
          )
        end

        def create_fake_specifications
          [
            {
              name: "Product Subscription",
              identifier: "subscription_management",
              features: {
                argo: {
                  surface: "admin",
                },
              },
            },
            {
              name: "Checkout Post Purchase",
              identifier: "checkout_post_purchase",
              features: {
                argo: {
                  surface: "checkout",
                },
              },
            },
          ]
        end
      end
    end
  end
end
