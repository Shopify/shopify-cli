module Extension
  module Tasks
    class FetchSpecifications
      include ShopifyCli::MethodObject

      def call
        [
          product_subscription_specification,
          checkout_post_purchase_specification,
        ]
      end

      private

      def product_subscription_specification
        {
          identifier: 'product_subscription',
          features: {
            argo: {
              surface_area: 'admin',
            },
          },
        }
      end

      def checkout_post_purchase_specification
        {
          identifier: 'checkout_post_purchase',
          features: {
            argo: {
              surface_area: 'checkout',
            },
          },
        }
      end
    end
  end
end
