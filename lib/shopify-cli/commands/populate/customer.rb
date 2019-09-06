require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class Customer < Resource
        @type = :customer
        @field = :customerCreate
        @input_type = :CustomerInput
        @payload = :CustomerCreatePayload
        @payload_blacklist = %w()

        def defaults
          first_name, last_name = Helpers::Haikunator.name
          @input.firstName = first_name
          @input.lastName = last_name
        end

        def message(data)
          ret = data['customerCreate']['customer']
          id = API.gid_to_id(ret['id'])
          "#{ret['displayName']} added to {{green:#{Project.current.env.shop}}} at "\
          "{{underline:#{admin_url}customers/#{id}}}"
        end
      end
    end
  end
end
