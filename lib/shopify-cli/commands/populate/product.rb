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
          @store = ret['vendor']
          id = @api.gid_to_id(ret['id'])
          "#{ret['title']} added to {{green:#{@store}}} at #{admin_url('product', id)}"
        end

        def success
          <<~SUCCESS
            {{v}} Successfully added products to {{green:#{@store}}}
            {{*}} View all products at some https://#{Project.current.env.shop}/admin/products
          SUCCESS
        end

        def completion_message
          ctx.puts(success)
        end
      end
    end
  end
end
