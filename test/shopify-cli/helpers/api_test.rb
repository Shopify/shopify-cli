require 'test_helper'

module ShopifyCli
  module Helpers
    class APITest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @api = API.new(
          ctx: @context,
          token: 'faketoken',
          url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
        )
        @api.stubs(:current_sha).returns('abcde')
        @api.stubs(:uname).with(flag: 'v').returns('Mac')
      end

      def test_mutation_makes_request_to_shopify
        @api.stubs(:latest_api_version).returns('2019-04')
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
              'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac",
              'X-Shopify-Access-Token' => 'faketoken',
              'Authorization' => 'faketoken',
            })
          .to_return(status: 200, body: '{}')
        @api.mutation(mutation)
      end

      def test_latest_api_version
        query = '{ publicApiVersions() { handle displayName } }'
        stub_request(:post, 'https://my-test-shop.myshopify.com/admin/api/unstable/graphql.json')
          .with(body: JSON.dump(
              query: query,
              variables: {},
            ),
            headers: {
              'Content-Type' => 'application/json',
              'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac",
              'X-Shopify-Access-Token' => 'faketoken',
              'Authorization' => 'faketoken',
            })
          .to_return(
            status: 200,
            body: File.read(File.join(FIXTURE_DIR, 'api/versions.json')),
          )
        API.any_instance.stubs(:current_sha).returns('abcde')
        API.any_instance.stubs(:uname).with(flag: 'v').returns('Mac')
        api = API.new(ctx: @context, token: 'faketoken')
        assert_equal(api.url, 'https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json')
      end
    end
  end
end
