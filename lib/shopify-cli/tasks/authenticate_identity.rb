require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateIdentity < ShopifyCli::Task
      def call(ctx)
        token = oauth_client.authenticate("https://identity.myshopify.io/oauth")
        ctx.puts "{{success:Authentication Token #{token}}}"
      rescue OAuth::Error => e
        ctx.puts("{{error: #{e}}}")
      end

      private

      def oauth_client
        OAuth.new(
          client_id: 'e5380e02-312a-7408-5718-e07017e9cf52',
          scopes: ['openid', 'profile', 'email'],
        )
      end
    end
  end
end
