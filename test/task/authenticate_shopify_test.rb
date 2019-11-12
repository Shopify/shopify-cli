require 'test_helper'

module ShopifyCli
  module Tasks
    class AuthenticateShopifyTest < MiniTest::Test
      def test_negotiate_oauth_and_store_token
        @oauth_client = Object.new
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
        AuthenticateShopify.new.call(@context)
      end

      def test_authenticates_against_specified_shop
        @oauth_client = Object.new
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
          .with("https://other-test-shop.myshopify.com/admin/oauth")
        AuthenticateShopify.new.call(@context, shop: 'other-test-shop.myshopify.com')
      end
    end
  end
end
