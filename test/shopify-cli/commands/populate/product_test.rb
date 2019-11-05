require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ProductTest < MiniTest::Test
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        end

        def test_populate_calls_api_with_mutation
          Helpers::Haikunator.stubs(:title).returns('fake product')
          Resource.any_instance.stubs(:price).returns('1.00')
          ShopifyCli::Helpers::AdminAPI.expects(:query)
            .with(@context, 'create_product', input: {
              title: 'fake product',
              variants: [{ price: '1.00' }],
            })
            .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, 'populate/product_data.json'))))
          ShopifyCli::API.expects(:gid_to_id).returns(12345678)
          @context.expects(:done).with(
            "fake product added to {{green:my-test-shop.myshopify.com}} at" \
            " {{underline:https://my-test-shop.myshopify.com/admin/products/12345678}}"
          )
          run_cmd('populate products -c 1')
        end
      end
    end
  end
end
