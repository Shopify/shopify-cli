require 'shopify_cli'

module Rails
  module Commands
    class Populate
      class Product < ShopifyCli::AdminAPI::PopulateResourceCommand
        @input_type = :ProductInput

        def defaults
          { title: ShopifyCli::Helpers::Haikunator.title, variants: [{ price: price }] }
        end

        def message(data)
          ret = data['productCreate']['product']
          id = ShopifyCli::API.gid_to_id(ret['id'])
          @ctx.message(
            'rails.populate.product.added',
            ret['title'],
            ShopifyCli::Project.current.env.shop,
            admin_url,
            id,
          )
        end
      end
    end
  end
end
