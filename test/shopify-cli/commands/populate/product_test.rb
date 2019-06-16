require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ProductTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @context.stubs(:project).returns(
            Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
          )
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          @resource = Product.new(ctx: @context)
          @mutation = File.read(File.join(FIXTURE_DIR, 'populate/product.graphql'))
        end

        def test_populate_calls_api_with_mutation
          Helpers::Haikunator.stubs(:haikunate).returns('fake product')
          @resource.stubs(:price).returns('1.00')
          body = @resource.api.mutation_body(@mutation)
          stub_request(:post, "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json")
            .with(body: body,
               headers: {
                 'Content-Type' => 'application/json',
                 'User-Agent' => 'Shopify App CLI',
                 'X-Shopify-Access-Token' => 'myaccesstoken',
               })
            .to_return(
              status: 200,
              body: File.read(File.join(FIXTURE_DIR, 'populate/product_data.json')),
              headers: {}
            )
          @context.expects(:done).with(
            "product 'fake product' created: https://my-test-shop.myshopify.com/admin/products/12345678"
          )
          @resource.populate(1)
        end
      end
    end
  end
end
