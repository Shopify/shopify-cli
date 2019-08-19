require 'shopify_cli'

module ShopifyCli
  module Tasks
    class AuthenticateIdentity < ShopifyCli::Task
      SCOPES = 'openid https://api.shopify.com/auth/partners.app.cli.access'

      def call(_ctx)
        OAuth.new(
          service: 'identity',
          client_id: Helpers::PartnersAPI.cli_id,
          scopes: SCOPES,
          request_exchange: Helpers::PartnersAPI.id,
        ).authenticate("#{Helpers::PartnersAPI.auth_endpoint}/oauth")
      end
    end
  end
end
