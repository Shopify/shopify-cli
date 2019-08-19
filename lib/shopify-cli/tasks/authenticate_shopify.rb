require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateShopify < ShopifyCli::Task
      def call(ctx)
        Tasks::EnsureEnv.call(ctx)
        env = Helpers::EnvFile.read
        OAuth.new(
          service: 'admin',
          client_id: env.api_key,
          secret: env.secret,
          scopes: env.scopes,
          token_path: "/access_token",
          options: { 'grant_options[]' => 'per user' },
        ).authenticate("https://#{env.shop}/admin/oauth")
      end
    end
  end
end
