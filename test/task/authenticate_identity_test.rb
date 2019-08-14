require 'test_helper'

module ShopifyCli
  module Tasks
    class AuthenticateIdentityTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Constants

      def test_negotiate_oauth_and_store_token
        @oauth_client = Object.new
        ShopifyCli::OAuth
          .expects(:new)
          .with(
            client_id: 'fbdb2649-e327-4907-8f67-908d24cfd7e3',
            scopes: AuthenticateIdentity::SCOPES,
          ).returns(@oauth_client)
        @oauth_client
          .expects(:authenticate)
          .with("https://accounts.shopify.com/oauth")
          .returns("this_is_token")
        @oauth_client
          .expects(:exchange_token)
          .with(
            "https://accounts.shopify.com/oauth",
            token: "this_is_token",
            audience: '271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6',
            scopes: AuthenticateIdentity::SCOPES,
          )
          .returns("this_is_exchange_token")
        Helpers::PkceToken.expects(:write).with("this_is_exchange_token")
        AuthenticateIdentity.call(@context)
      end

      def test_handles_oauth_errors
        @oauth_client = Object.new
        ShopifyCli::OAuth.stubs(:new).returns(@oauth_client)
        @oauth_client
          .expects(:authenticate)
          .with("https://accounts.shopify.com/oauth")
          .raises(OAuth::Error, 'invalid request')
        assert_nothing_raised do
          AuthenticateIdentity.call(@context)
        end
      end
    end
  end
end
