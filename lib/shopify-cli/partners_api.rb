require 'shopify_cli'

module ShopifyCli
  class PartnersAPI < API
    autoload :Organizations, 'shopify-cli/partners_api/organizations'

    LOCAL_DEBUG = 'SHOPIFY_APP_CLI_LOCAL_PARTNERS'

    class << self
      def query(ctx, body, **variables)
        authenticated_req(ctx) do
          api_client(ctx).query(body, variables: variables)
        end
      end

      private

      def authenticated_req(ctx)
        yield
      rescue API::APIRequestUnauthorizedError
        authenticate(ctx)
        retry
      rescue API::APIRequestNotFoundError
        ctx.puts("{{x}} error: Your account was not found. Please sign up at https://partners.shopify.com/signup")
        ctx.puts(
          "For authentication issues, run {{command:#{ShopifyCli::TOOL_NAME} logout}} to clear invalid credentials"
        )
      end

      def api_client(ctx)
        new(
          ctx: ctx,
          token: access_token(ctx),
          url: "#{endpoint}/api/cli/graphql",
        )
      end

      def access_token(ctx)
        ShopifyCli::DB.get(:identity_exchange_token) do
          authenticate(ctx)
          ShopifyCli::DB.get(:identity_exchange_token)
        end
      end

      def authenticate(ctx)
        OAuth.new(
          ctx: ctx,
          service: 'identity',
          client_id: cli_id,
          scopes: 'openid https://api.shopify.com/auth/partners.app.cli.access',
          request_exchange: partners_id,
        ).authenticate("#{auth_endpoint}/oauth")
      end

      def partners_id
        ENV[LOCAL_DEBUG].nil? ?
          '271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6' :
          'df89d73339ac3c6c5f0a98d9ca93260763e384d51d6038da129889c308973978'
      end

      def cli_id
        ENV[LOCAL_DEBUG].nil? ?
          'fbdb2649-e327-4907-8f67-908d24cfd7e3' :
          'e5380e02-312a-7408-5718-e07017e9cf52'
      end

      def auth_endpoint
        ENV[LOCAL_DEBUG].nil? ?
          'https://accounts.shopify.com' :
          'https://identity.myshopify.io'
      end

      def endpoint
        ENV[LOCAL_DEBUG].nil? ?
          'https://partners.shopify.com' :
          'https://partners.myshopify.io/'
      end
    end

    def auth_headers(token)
      { Authorization: "Bearer #{token}" }
    end
  end
end
