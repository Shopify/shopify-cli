require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class Product < Resource
        @type = :product
        @field = :productCreate
        @input_type = :ProductInput
        @payload = :ProductCreatePayload
        @payload_blacklist = %w(
          availablePublicationCount
          publishedOnCurrentChannel
          publishedOnCurrentPublication
        )

        def defaults
          @input.title = Helpers::Haikunator.title
          @input.variants = "[{price: \"#{price}\"}]"
        end

        def message(data)
          ret = data['productCreate']['product']
          id = @api.gid_to_id(ret['id'])
          "product '#{ret['title']}' created: #{admin_url('product', id)}"
        end
      end
    end
  end
end
