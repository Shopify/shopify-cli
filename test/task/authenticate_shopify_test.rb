require 'test_helper'

module ShopifyCli
  module Tasks
    class AuthenticateShopifyTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Constants

      def test_negotiate_oauth_and_store_token
        @oauth_client = Object.new
        ShopifyCli::OAuth
          .expects(:new)
          .with(
            client_id: 'apikey',
            secret: 'secret',
            scopes: nil,
            token_path: "/access_token",
            options: { 'grant_options[]' => 'per user' },
          ).returns(@oauth_client)
        @oauth_client
          .expects(:authenticate)
          .with("https://my-test-shop.myshopify.com/admin/oauth")
          .returns("this_is_token")
        Helpers::AccessToken.expects(:write).with("this_is_token")
        AuthenticateShopify.new.call(@context)
      end

      def test_handles_oauth_errors
        @oauth_client = Object.new
        ShopifyCli::OAuth.stubs(:new).returns(@oauth_client)
        @oauth_client
          .expects(:authenticate)
          .with("https://my-test-shop.myshopify.com/admin/oauth")
          .raises(OAuth::Error, 'invalid request')
        @oauth_client.expects(:redirect_uri).returns("http://localhost:3456")
        assert_nothing_raised do
          AuthenticateShopify.new.call(@context)
        end
      end
    end
  end
end
