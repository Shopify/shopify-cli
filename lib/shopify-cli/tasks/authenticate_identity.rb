require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateIdentity < ShopifyCli::Task
      SCOPES = 'openid https://api.shopify.com/auth/partners.app.cli.access'

      def call(ctx)
        client = oauth_client
        auth_endpoint = "#{Helpers::PartnersAPI.auth_endpoint}/oauth"
        exchange = client.exchange_token(
          auth_endpoint,
          token: client.authenticate(auth_endpoint),
          audience: Helpers::PartnersAPI.id,
          scopes: SCOPES,
        )
        Helpers::PkceToken.write(exchange)
        ctx.puts "{{success:Authentication Token saved}}"
      rescue OAuth::Error => e
        ctx.puts("{{error: #{e}}}")
      end

      private

      def oauth_client
        OAuth.new(client_id: Helpers::PartnersAPI.cli_id, scopes: SCOPES)
      end
    end
  end
end
