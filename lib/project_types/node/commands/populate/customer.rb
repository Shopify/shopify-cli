require 'shopify_cli'

module Node
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
          ret = data['customerCreate']['customer']
          id = ShopifyCli::API.gid_to_id(ret['id'])
          "#{ret['displayName']} added to {{green:#{ShopifyCli::Project.current.env.shop}}} "\
          "at {{underline:#{admin_url}customers/#{id}}}"
        end
      end
    end
  end
end
