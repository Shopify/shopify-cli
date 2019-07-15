require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateShopify < ShopifyCli::Task
      def call(ctx)
        Tasks::EnsureEnv.call(ctx)
        token = oauth_client.authenticate("https://#{env.shop}/admin/oauth")
        @env = Helpers::AccessToken.write(token)
        ctx.puts "{{success:Authentication Token written to env file}}"
      rescue OAuth::Error => e
        ctx.puts("{{error: #{e}}}")
        ctx.puts("{{error:Failed to retrieve ID & Refresh tokens}}")
        ctx.puts "{{*}} Remeber to add {{underline: #{oauth_client.redirect_uri} "\
          "to the whitelisted redirection URLs in your app setup"
      end

      private

      def env
        @env = Helpers::EnvFile.read
      end

      def oauth_client
        OAuth.new(
          client_id: env.api_key,
          secret: env.secret,
          scopes: env.scopes,
          token_path: "/access_token",
          options: { 'grant_options[]' => 'per user' },
        )
      end
    end
  end
end
