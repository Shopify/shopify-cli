require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class DraftOrder < Resource
        @input_type = :DraftOrderInput

        def defaults
          @input.lineItems = [{
            originalUnitPrice: price,
            quantity: 1,
            weight: { value: 10, unit: 'GRAMS' },
            title: Helpers::Haikunator.title,
          }]
        end

        def message(data)
          ret = data['draftOrderCreate']['draftOrder']
          id = API.gid_to_id(ret['id'])
          "DraftOrders added to {{green:#{Project.current.env.shop}}} at {{underline:#{admin_url}draft_orders/#{id}}}"
        end
      end
    end
  end
end
