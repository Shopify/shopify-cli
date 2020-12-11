require 'test_helper'

module ShopifyCli
  class AdminAPITest < MiniTest::Test
    include TestHelpers::Project

    def test_latest_api_version
      unstable_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'token123',
        url: "https://my-test-shop.myshopify.com/admin/api/unstable/graphql.json",
      ).returns(unstable_stub)
      unstable_stub.expects(:query)
        .with('api_versions')
        .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, 'api/versions.json'))))

      ShopifyCli::DB.expects(:get).with(:admin_access_token).returns('token123').twice
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'token123',
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with('query', variables: {}).returns('response')
      assert_equal 'response', AdminAPI.query(@context, 'query', shop: 'my-test-shop.myshopify.com')
    end

    def test_query_calls_admin_api
      ShopifyCli::DB.expects(:get).with(:admin_access_token).returns('token123')
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'token123',
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with('query', variables: {}).returns('response')
      assert_equal(
        'response',
        AdminAPI.query(@context, 'query', shop: 'my-test-shop.myshopify.com', api_version: '2019-04'),
      )
    end

    def test_rest_request_calls_admin_api
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'boop',
        url: 'https://shop.myshopify.com/admin/api/unstable/data.json',
      ).returns(api_stub)
      api_stub.expects(:request).with(url: 'https://shop.myshopify.com/admin/api/unstable/data.json',
                                      body: nil,
                                      method: "GET").returns('response')
      assert_equal(
        'response',
        AdminAPI.rest_request(@context,
                             shop: 'shop.myshopify.com',
                             path: 'data.json',
                             api_version: 'unstable',
                             token: 'boop'),
      )
    end

    def test_query_can_reauth
      ShopifyCli::DB.expects(:get).with(:admin_access_token).returns('token123').twice
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'token123',
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub).twice
      api_stub.expects(:query).with('query', variables: {}).returns('response')
      api_stub.expects(:query).raises(API::APIRequestUnauthorizedError)

      @oauth_client = mock
      ShopifyCli::OAuth
        .expects(:new)
        .with(
          ctx: @context,
          service: 'admin',
          client_id: 'apikey',
          secret: 'secret',
          scopes: nil,
          token_path: "/access_token",
          options: { 'grant_options[]' => 'per user' },
        ).returns(@oauth_client)
      @oauth_client
        .expects(:authenticate)
        .with("https://my-test-shop.myshopify.com/admin/oauth")

      AdminAPI.query(@context, 'query', shop: 'my-test-shop.myshopify.com', api_version: '2019-04')
    end

    def test_query_calls_admin_api_with_different_shop
      ShopifyCli::DB.expects(:get).with(:admin_access_token).returns('token123')
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: 'X-Shopify-Access-Token',
        token: 'token123',
        url: "https://other-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with('query', variables: {}).returns('response')
      assert_equal 'response', AdminAPI.query(
        @context, 'query', shop: 'other-test-shop.myshopify.com', api_version: '2019-04'
      )
    end
  end
end
