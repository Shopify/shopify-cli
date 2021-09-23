require "shopify_cli"

module ShopifyCLI
  module Commands
    class Populate
      class DraftOrder < ShopifyCLI::AdminAPI::PopulateResourceCommand
        @input_type = :DraftOrderInput

        def defaults
          {
            lineItems: [{
              originalUnitPrice: price,
              quantity: 1,
              weight: { value: 10, unit: "GRAMS" },
              title: ShopifyCLI::Helpers::Haikunator.title,
            }],
          }
        end

        def message(data)
          ret = data["draftOrderCreate"]["draftOrder"]
          id = ShopifyCLI::API.gid_to_id(ret["id"])
          @ctx.message("core.populate.draft_order.added", @shop, admin_url, id)
        end
      end
    end
  end
end
