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
          id = @api.gid_to_id(ret['id'])
          "customer '#{ret['displayName']}' created: #{admin_url('customer', id)}"
        end
      end
    end
  end
end
