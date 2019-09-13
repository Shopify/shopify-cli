require 'shopify_cli'

module ShopifyCli
  module Helpers
    class PartnersAPI < API
      ENV_VAR = 'SHOPIFY_APP_CLI_LOCAL_PARTNERS'
      AUTH_PROD_URI = 'https://accounts.shopify.com'
      AUTH_DEV_URI = 'https://identity.myshopify.io'
      PROD_URI = 'https://partners.shopify.com'
      DEV_URI = 'https://partners.myshopify.io/'
      PROD_ID = '271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6'
      DEV_ID = 'df89d73339ac3c6c5f0a98d9ca93260763e384d51d6038da129889c308973978'
      PROD_CLI_ID = 'fbdb2649-e327-4907-8f67-908d24cfd7e3'
      DEV_CLI_ID = 'e5380e02-312a-7408-5718-e07017e9cf52'

      class << self
        def id
          ENV[ENV_VAR].nil? ? PROD_ID : DEV_ID
        end

        def cli_id
          ENV[ENV_VAR].nil? ? PROD_CLI_ID : DEV_CLI_ID
        end

        def auth_endpoint
          ENV[ENV_VAR].nil? ? AUTH_PROD_URI : AUTH_DEV_URI
        end

        def endpoint
          ENV[ENV_VAR].nil? ? PROD_URI : DEV_URI
        end

        def query(ctx, body, **variables)
          authenticated_req(ctx) do
            api_client(ctx).query(body, variables: variables)
          end
        end

        private

        def authenticated_req(ctx)
          yield
        rescue API::APIRequestUnauthorizedError
          Tasks::AuthenticateIdentity.call(ctx)
          retry
        rescue API::APIRequestNotFoundError
          ctx.puts("{{error: Your account was not found. Please sign up at https://partners.shopify.com/signup}}")
        end

        def api_client(ctx)
          new(
            ctx: ctx,
            token: Helpers::PkceToken.read(ctx),
            url: "#{endpoint}/api/cli/graphql",
          )
        end
      end

      def auth_headers(token)
        { Authorization: "Bearer #{token}" }
      end
    end
  end
end
