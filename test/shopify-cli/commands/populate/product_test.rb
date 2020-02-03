require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ProductTest < MiniTest::Test
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          @cmd = ShopifyCli::Commands::Populate
          @cmd.ctx = @context
        end

        def test_populate_calls_api_with_mutation
          Helpers::Haikunator.expects(:title).returns('fake product')
          Helpers::Haikunator.expects(:title).returns('fake producttwo')
          Resource.any_instance.stubs(:price).returns('1.00')
          return_data = JSON.parse(File.read(File.join(FIXTURE_DIR, 'populate/product_data.json')))
          ShopifyCli::Helpers::AdminAPI.expects(:query)
            .with(@context, 'create_product', input: {
              'title': 'fake product',
              variants: [{ price: '1.00' }],
            })
            .returns(return_data)
          ShopifyCli::Helpers::AdminAPI.expects(:query)
            .with(@context, 'create_product', input: {
              'title': 'fake producttwo',
              variants: [{ price: '1.00' }],
            })
            .returns(return_data)
          ShopifyCli::API.expects(:gid_to_id).returns(12345678).twice
          @context.expects(:done).with(
            "fake product added to {{green:my-test-shop.myshopify.com}} at" \
            " {{underline:https://my-test-shop.myshopify.com/admin/products/12345678}}"
          ).twice
          @cmd.call(['products', '-c', '2'], 'populate')
        end
      end
    end
  end
end
