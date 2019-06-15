require 'test_helper'

module ShopifyCli
  module Helpers
    class APITest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @api = API.new(ctx: @context, token: 'faketoken')
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
        )
      end

      def test_mutation_makes_request_to_shopify
        mutation = <<~MUTATION
          fakeMutation(input: {
            title: "fake title"
          }) {
            id
          }
        MUTATION
        stub_request(:post, 'https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json')
          .with(body: File.read(File.join(FIXTURE_DIR, 'api/mutation.json')).tr("\n", ''),
            headers: {
              'Content-Type' => 'application/json',
              'User-Agent' => 'Shopify App CLI',
              'X-Shopify-Access-Token' => 'faketoken',
            })
          .to_return(status: 200, body: '{}')
        @api.mutation(mutation)
      end
    end
  end
end
