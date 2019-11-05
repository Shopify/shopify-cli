require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class DraftOrderTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        end

        def test_populate_calls_api_with_mutation
          Helpers::Haikunator.stubs(:title).returns('fake order')
          ShopifyCli::Helpers::AdminAPI.expects(:query)
            .with(@context, 'create_draftorder', input: {
              lineItems: [{
                originalUnitPrice: "1.00",
                quantity: 1,
                weight: { value: 10, unit: 'GRAMS' },
                title: 'fake order',
              }],
            })
            .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, 'populate/draft_order_data.json'))))
          ShopifyCli::API.expects(:gid_to_id).returns(12345678)
          Resource.any_instance.stubs(:price).returns('1.00')
          @context.expects(:done).with(
            "DraftOrders added to {{green:my-test-shop.myshopify.com}} at " \
            "{{underline:https://my-test-shop.myshopify.com/admin/draft_orders/12345678}}"
          )
          run_cmd('populate draftorders -c 1')
        end
      end
    end
  end
end
