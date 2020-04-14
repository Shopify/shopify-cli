require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateIdentity < ShopifyCli::Task
      SCOPES = 'openid https://api.shopify.com/auth/partners.app.cli.access'

      def call(ctx)
        OAuth.new(
          ctx: ctx,
          service: 'identity',
          client_id: ShopifyCli::PartnersAPI.cli_id,
          scopes: SCOPES,
          request_exchange: ShopifyCli::PartnersAPI.id,
        ).authenticate("#{ShopifyCli::PartnersAPI.auth_endpoint}/oauth")
      end
    end
  end
end
