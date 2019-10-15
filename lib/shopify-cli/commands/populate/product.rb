require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class Product < Resource
        @input_type = :ProductInput

        def defaults
          @input.title = Helpers::Haikunator.title
          @input.variants = [{ price: price }]
        end

        def message(data)
          ret = data['productCreate']['product']
          id = API.gid_to_id(ret['id'])
          "#{ret['title']} added to {{green:#{Project.current.env.shop}}} at {{underline:#{admin_url}products/#{id}}}"
        end
      end
    end
  end
end
