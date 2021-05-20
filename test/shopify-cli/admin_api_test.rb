require "test_helper"

module ShopifyCli
  class AdminAPITest < MiniTest::Test
    include TestHelpers::Project

    def test_latest_api_version
      unstable_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://my-test-shop.myshopify.com/admin/api/unstable/graphql.json",
      ).returns(unstable_stub)
      unstable_stub.expects(:query)
        .with("api_versions")
        .returns(JSON.parse(File.read(File.join(FIXTURE_DIR, "api/versions.json"))))

      ShopifyCli::DB.expects(:get).with(:shopify_exchange_token).returns("token123").twice
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with("query", variables: {}).returns("response")
      assert_equal "response", AdminAPI.query(@context, "query", shop: "my-test-shop.myshopify.com")
    end

    def test_query_calls_admin_api
      ShopifyCli::DB.expects(:get).with(:shopify_exchange_token).returns("token123")
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with("query", variables: {}).returns("response")
      assert_equal(
        "response",
        AdminAPI.query(@context, "query", shop: "my-test-shop.myshopify.com", api_version: "2019-04"),
      )
    end

    def test_rest_request_calls_admin_api
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "boop",
        url: "https://shop.myshopify.com/admin/api/unstable/data.json",
      ).returns(api_stub)
      api_stub.expects(:request).with(url: "https://shop.myshopify.com/admin/api/unstable/data.json",
                                      body: nil,
                                      method: "GET").returns("response")
      assert_equal(
        "response",
        AdminAPI.rest_request(@context,
          shop: "shop.myshopify.com",
          path: "data.json",
          api_version: "unstable",
          token: "boop"),
      )
    end

    def test_query_can_reauth
      ShopifyCli::DB.expects(:get).with(:shopify_exchange_token).returns("token123")
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with("query", variables: {}).returns("response")
      api_stub.expects(:query).raises(API::APIRequestUnauthorizedError)

      @identity_auth_client = mock
      ShopifyCli::IdentityAuth
        .expects(:new)
        .with(ctx: @context)
        .returns(@identity_auth_client)
      @identity_auth_client
        .expects(:reauthenticate)

      assert_equal(
        "response",
        AdminAPI.query(@context, "query", shop: "my-test-shop.myshopify.com", api_version: "2019-04"),
      )
    end

    def test_rest_request_can_reauth
      ShopifyCli::DB.expects(:get).with(:shopify_exchange_token).returns("token123").twice
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://shop.myshopify.com/admin/api/unstable/data.json",
      ).returns(api_stub).twice
      api_stub.expects(:request).with(url: "https://shop.myshopify.com/admin/api/unstable/data.json",
        body: nil,
        method: "GET").returns("response")
      api_stub.expects(:request).raises(API::APIRequestUnauthorizedError)

      @identity_auth_client = mock
      ShopifyCli::IdentityAuth
        .expects(:new)
        .with(ctx: @context)
        .returns(@identity_auth_client)
      @identity_auth_client
        .expects(:reauthenticate)

      assert_equal(
        "response",
        AdminAPI.rest_request(@context,
          shop: "shop.myshopify.com",
          path: "data.json",
          api_version: "unstable",
          token: "boop"),
      )
    end

    def test_query_calls_admin_api_with_different_shop
      ShopifyCli::DB.expects(:get).with(:shopify_exchange_token).returns("token123")
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        token: "token123",
        url: "https://other-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub)
      api_stub.expects(:query).with("query", variables: {}).returns("response")
      assert_equal "response", AdminAPI.query(
        @context, "query", shop: "other-test-shop.myshopify.com", api_version: "2019-04"
      )
    end

    def test_query_fails_gracefully_when_unable_to_authenticate
      ShopifyCli::DB.expects(:get).with(:admin_access_token).returns("token123").twice
      api_stub = stub
      AdminAPI.expects(:new).with(
        ctx: @context,
        auth_header: "X-Shopify-Access-Token",
        token: "token123",
        url: "https://shop.myshopify.com/admin/api/2019-04/graphql.json",
      ).returns(api_stub).twice
      api_stub.expects(:query).raises(API::APIRequestUnauthorizedError).twice

      @oauth_client = mock
      ShopifyCli::OAuth.expects(:new).returns(@oauth_client)
      @oauth_client.expects(:authenticate).with("https://shop.myshopify.com/admin/oauth")

      io = capture_io_and_assert_raises(ShopifyCli::Abort) do
        AdminAPI.query(@context, "query", shop: "shop.myshopify.com", api_version: "2019-04")
      end
      assert_message_output(
        io: io,
        expected_content: [
          @context.message("core.api.error.failed_auth"),
        ]
      )
    end
  end
end
