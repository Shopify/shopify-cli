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
            service: 'identity',
            client_id: Helpers::PartnersAPI.cli_id,
            scopes: AuthenticateIdentity::SCOPES,
            request_exchange: Helpers::PartnersAPI.id,
          ).returns(@oauth_client)
        @oauth_client
          .expects(:authenticate)
          .with("https://accounts.shopify.com/oauth")
        AuthenticateIdentity.call(@context)
      end
    end
  end
end
