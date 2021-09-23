require "shopify_cli"

module ShopifyCLI
  module Commands
    class Populate
      class Product < ShopifyCLI::AdminAPI::PopulateResourceCommand
        @input_type = :ProductInput

        def defaults
          {
            title: ShopifyCLI::Helpers::Haikunator.title,
            variants: [{ price: price }],
          }
        end

        def message(data)
          ret = data["productCreate"]["product"]
          id = ShopifyCLI::API.gid_to_id(ret["id"])
          @ctx.message("core.populate.product.added", ret["title"], @shop, admin_url, id)
        end
      end
    end
  end
end
