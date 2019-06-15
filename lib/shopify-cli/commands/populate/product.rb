require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class Product < Resource
        def mutation
          <<~MUTATION
            productCreate(input: {
              title: "#{Helpers::Haikunator.haikunate(0, ' ')}",
              variants: [{
                price: "1.00"
              }]
            }) {
              product {
                id,
                title,
                onlineStoreUrl,
              }
              userErrors {
                message
              }
            }
          MUTATION
        end

        def message(data)
          ret = data['productCreate']['product']
          id = @api.gid_to_id(ret['id'])
          "product '#{ret['title']}' created: #{admin_url('product', id)}"
        end
      end
    end
  end
end
