# frozen_string_literal: true
require "project_types/node/test_helper"

module ShopifyCli
  module Commands
    module PopulateTests
      class CustomerTest < MiniTest::Test
        include TestHelpers::Schema

        def test_populate_calls_api_with_mutation
          ShopifyCli::Helpers::Haikunator.stubs(:name).returns(["first", "last"])
          ShopifyCli::DB.expects(:exists?).with(:shop).returns(true).twice
          ShopifyCli::DB.expects(:get).with(:shop).returns("my-test-shop.myshopify.com").twice
          CLI::UI::Prompt.expects(:confirm)
            .with(@context.message("core.tasks.confirm_store.prompt", "my-test-shop.myshopify.com"), default: false)
            .returns(true)
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

        def test_populate_if_no_shop
          ShopifyCli::DB.expects(:exists?).with(:shop).returns(false)
          ShopifyCli::AdminAPI.expects(:query).never
          exception = assert_raises ShopifyCli::Abort do
            run_cmd("populate customers")
          end
          assert_equal(
            "{{x}} " + @context.message("core.populate.error.no_shop", ShopifyCli::TOOL_NAME),
            exception.message
          )
        end
      end
    end
  end
end
