# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    module PopulateTests
      class CustomerTest < MiniTest::Test
        include TestHelpers::Schema

        def test_populate_calls_api_with_mutation
          ShopifyCli::Helpers::Haikunator.stubs(:name).returns(["first", "last"])
          ShopifyCli::AdminAPI.expects(:query)
            .with(@context, "create_customer", shop: "my-test-shop.myshopify.com", input: {
              firstName: "first",
              lastName: "last",
            })
            .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, "populate/customer_data.json"))))
          ShopifyCli::API.expects(:gid_to_id).returns(12345678)
          ShopifyCli::AdminAPI::PopulateResourceCommand.any_instance.stubs(:price).returns("1.00")
          @context.expects(:done).with(
            "first last added to {{green:my-test-shop.myshopify.com}} at " \
            "{{underline:https://my-test-shop.myshopify.com/admin/customers/12345678}}"
          )
          run_cmd("populate customers -c 1")
        end
      end
    end
  end
end
