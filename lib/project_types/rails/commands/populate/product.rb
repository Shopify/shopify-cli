require 'shopify_cli'

module Rails
  module Commands
    class Populate
      class Product < ShopifyCli::AdminAPI::PopulateResourceCommand
        @input_type = :ProductInput

        def defaults
          {
            title: ShopifyCli::Helpers::Haikunator.title,
            variants: [{ price: price }],
          }
        end

        def message(data)
          ret = data['productCreate']['product']
          id = ShopifyCli::API.gid_to_id(ret['id'])
          "#{ret['title']} added to {{green:#{ShopifyCli::Project.current.env.shop}}} "\
          "at {{underline:#{admin_url}products/#{id}}}"
        end
      end
    end
  end
end
