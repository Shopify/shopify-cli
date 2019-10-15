require 'test_helper'

module ShopifyCli
  module Helpers
    class AdminAPITest < MiniTest::Test
      include TestHelpers::Project

      def test_latest_api_version
        unstable_stub = Object.new
        AdminAPI.expects(:new).with(
          ctx: @context,
          auth_header: 'X-Shopify-Access-Token',
          token: 'token123',
          url: "https://my-test-shop.myshopify.com/admin/api/unstable/graphql.json",
        ).returns(unstable_stub)
        unstable_stub.expects(:query)
          .with('api_versions')
          .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, 'api/versions.json'))))

        Helpers::AccessToken.expects(:read).returns('token123').twice
        api_stub = Object.new
        AdminAPI.expects(:new).with(
          ctx: @context,
          auth_header: 'X-Shopify-Access-Token',
          token: 'token123',
          url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
        ).returns(api_stub)
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        assert_equal 'response', AdminAPI.query(@context, 'query')
      end

      def test_query_calls_admin_api
        Helpers::AccessToken.expects(:read).returns('token123')
        api_stub = Object.new
        AdminAPI.expects(:new).with(
          ctx: @context,
          auth_header: 'X-Shopify-Access-Token',
          token: 'token123',
          url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
        ).returns(api_stub)
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        assert_equal 'response', AdminAPI.query(@context, 'query', api_version: '2019-04')
      end

      def test_query_can_reauth
        Helpers::AccessToken.expects(:read).returns('token123').twice
        api_stub = Object.new
        AdminAPI.expects(:new).with(
          ctx: @context,
          auth_header: 'X-Shopify-Access-Token',
          token: 'token123',
          url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
        ).returns(api_stub).twice
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        api_stub.expects(:query).raises(API::APIRequestUnauthorizedError)
        Tasks::AuthenticateShopify.expects(:call)
        AdminAPI.query(@context, 'query', api_version: '2019-04')
      end
    end
  end
end
