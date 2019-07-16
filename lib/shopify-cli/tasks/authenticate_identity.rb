require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateIdentity < ShopifyCli::Task
      def call(ctx)
        token = oauth_client.authenticate("https://accounts.shopify.com/oauth")
        Helpers::PkceToken.write(token)
        ctx.puts "{{success:Authentication Token saved}}"
      rescue OAuth::Error => e
        ctx.puts("{{error: #{e}}}")
      end

      private

      def oauth_client
        OAuth.new(
          client_id: 'fbdb2649-e327-4907-8f67-908d24cfd7e3',
          scopes: ['openid'],
        )
      end
    end
  end
end
