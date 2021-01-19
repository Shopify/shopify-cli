module Extension
  module Specifications
    class FakeDataRepository
      def get(identifier)
        all.yield_ok do |specifications|
          specifications.first { |specification| specification.identifier == identifier }
        end
      end

      def all
        Result.ok([
          {
            identifier: 'checkout_post_purchase',
            name: 'Checkout Post Purchase'
          },
          {
            identifier: 'product_subscription',
            name: 'Product Subscription'
          }
        ])
      end
    end
  end
end
