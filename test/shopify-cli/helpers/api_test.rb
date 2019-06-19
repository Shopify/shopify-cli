require 'test_helper'

module ShopifyCli
  module Helpers
    class APITest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @api = API.new(ctx: @context, token: 'faketoken')
        @api.stubs(:latest_api_version).returns('2019-04')
        @api.stubs(:current_sha).returns('abcde')
        @api.stubs(:uname).with(flag: 'v').returns('Mac')
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
        )
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
            })
          .to_return(status: 200, body: '{}')
        @api.mutation(mutation)
      end

      def test_latest_api_version
        query = <<~QUERY
          {
            publicApiVersions() {
              handle
              displayName
            }
          }
        QUERY
        stub_request(:post, 'https://my-test-shop.myshopify.com/admin/api/unstable/graphql.json')
          .with(body: @api.query_body(query),
            headers: {
              'Content-Type' => 'application/json',
              'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac",
              'X-Shopify-Access-Token' => 'faketoken',
            })
          .to_return(
            status: 200,
            body: File.read(File.join(FIXTURE_DIR, 'api/versions.json')),
          )
        assert_equal(@api.fetch_latest_api_version, '2019-04')
      end
    end
  end
end
