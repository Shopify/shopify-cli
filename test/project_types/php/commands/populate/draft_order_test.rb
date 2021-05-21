# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    module PopulateTests
      class DraftOrderTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::Schema

        def test_populate_calls_api_with_mutation
          ShopifyCli::Helpers::Haikunator.stubs(:title).returns("fake order")
          ShopifyCli::AdminAPI.expects(:query)
            .with(@context, "create_draft_order", shop: "my-test-shop.myshopify.com", input: {
              lineItems: [{
                originalUnitPrice: "1.00",
                quantity: 1,
                weight: { value: 10, unit: "GRAMS" },
                title: "fake order",
              }],
            })
            .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, "populate/draft_order_data.json"))))
          ShopifyCli::API.expects(:gid_to_id).returns(12345678)
          ShopifyCli::AdminAPI::PopulateResourceCommand.any_instance.stubs(:price).returns("1.00")
          @context.expects(:done).with(
            "DraftOrder added to {{green:my-test-shop.myshopify.com}} at " \
            "{{underline:https://my-test-shop.myshopify.com/admin/draft_orders/12345678}}"
          )
          run_cmd("populate draftorders -c 1")
        end
      end
    end
  end
end
