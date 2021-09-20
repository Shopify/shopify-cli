require "shopify_cli"

module ShopifyCli
  module Commands
    class Populate
      class Customer < ShopifyCli::AdminAPI::PopulateResourceCommand
        @input_type = :CustomerInput

        def defaults
          first_name, last_name = ShopifyCli::Helpers::Haikunator.name
          {
            firstName: first_name,
            lastName: last_name,
          }
        end

        def message(data)
          ret = data["customerCreate"]["customer"]
          id = ShopifyCli::API.gid_to_id(ret["id"])
          @ctx.message("core.populate.customer.added", ret["displayName"], @shop, admin_url, id)
        end
      end
    end
  end
end
