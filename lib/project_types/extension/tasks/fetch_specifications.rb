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
        Models::Specification.new(identifier: 'product_subscription')
      end

      def checkout_post_purchase_specification
        Models::Specification.new(identifier: 'checkout_post_purchase')
      end
    end
  end
end
