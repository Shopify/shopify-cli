require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate
      class DraftOrder < Resource
        @type = :draftOrder
        @field = :draftOrderCreate
        @input_type = :DraftOrderInput
        @payload = :DraftOrderCreatePayload
        @payload_blacklist = %w()

        def defaults
          @input.lineItems = <<~ITEM
            [{
              originalUnitPrice: "#{price}",
              quantity: 1,
              weight: {value: 10, unit: GRAMS},
              title: "#{Helpers::Haikunator.title}"
            }]
          ITEM
        end

        def message(data)
          ret = data['draftOrderCreate']['draftOrder']
          id = @api.gid_to_id(ret['id'])
          "draft order created: #{admin_url('draft_order', id)}"
        end
      end
    end
  end
end
