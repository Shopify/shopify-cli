require "shopify_cli"

module ShopifyCLI
  module Commands
    class Populate
      class Customer < ShopifyCLI::AdminAPI::PopulateResourceCommand
        @input_type = :CustomerInput

        def defaults
          first_name, last_name = ShopifyCLI::Helpers::Haikunator.name
          {
            firstName: first_name,
            lastName: last_name,
          }
        end

        def message(data)
          ret = data["customerCreate"]["customer"]
          id = ShopifyCLI::API.gid_to_id(ret["id"])
          @ctx.message("core.populate.customer.added", ret["displayName"], @shop, admin_url, id)
        end
      end
    end
  end
end
