require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class CustomerTest < MiniTest::Test
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        end

        def test_populate_calls_api_with_mutation
          Helpers::Haikunator.stubs(:name).returns(['first', 'last'])
          ShopifyCli::Helpers::AdminAPI.expects(:query)
            .with(@context, 'create_customer', input: {
              firstName: 'first',
              lastName: 'last',
            })
            .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, 'populate/customer_data.json'))))
          ShopifyCli::API.expects(:gid_to_id).returns(12345678)
          Resource.any_instance.stubs(:price).returns('1.00')
          @context.expects(:done).with(
            "first last added to {{green:my-test-shop.myshopify.com}} at " \
            "{{underline:https://my-test-shop.myshopify.com/admin/customers/12345678}}"
          )
          run_cmd('populate customers -c 1')
        end
      end
    end
  end
end
