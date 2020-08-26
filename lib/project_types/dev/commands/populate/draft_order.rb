require 'shopify_cli'

module Dev
  module Commands
    class Populate
      class DraftOrder < ShopifyCli::AdminAPI::PopulateResourceCommand
        @input_type = :DraftOrderInput

        def defaults
          {
            lineItems: [{
              originalUnitPrice: price,
              quantity: 1,
              weight: { value: 10, unit: 'GRAMS' },
              title: ShopifyCli::Helpers::Haikunator.title,
            }],
          }
        end

        def message(data)
          ret = data['draftOrderCreate']['draftOrder']
          id = ShopifyCli::API.gid_to_id(ret['id'])
          @ctx.message('dev.populate.draft_order.added', ShopifyCli::Project.current.env.shop, admin_url, id)
        end
      end
    end
  end
end
