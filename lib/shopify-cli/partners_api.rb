require 'shopify_cli'

module ShopifyCli
  ##
  # ShopifyCli::PartnersAPI provides easy access to the partners dashboard CLI
  # schema.
  #
  class PartnersAPI < API
    autoload :Organizations, 'shopify-cli/partners_api/organizations'

    # Defines the environment variable that this API looks for to operate on local
    # services. If you set this environment variable in your shell then the partners
    # api will operation on your local instance
    #
    # #### Example
    #
    #  SHOPIFY_APP_CLI_LOCAL_PARTNERS=1 shopify create
    #
    LOCAL_DEBUG = 'SHOPIFY_APP_CLI_LOCAL_PARTNERS'

    class << self
      ##
      # issues a graphql query or mutation to the Shopify Partners Dashboard CLI Schema.
      # It loads a graphql query from a file so that you do not need to use large
      # unwieldy query strings. It also handles authentication for you as well.
      #
      # #### Parameters
      # - `ctx`: running context from your command
      # - `query_name`: name of the query you want to use, loaded from the `lib/graphql` directory.
      # - `**variables`: a hash of variables to be supplied to the query or mutation
      #
      # #### Raises
      #
      # * http 404 will raise a ShopifyCli::API::APIRequestNotFoundError
      # * http 400..499 will raise a ShopifyCli::API::APIRequestClientError
      # * http 500..599 will raise a ShopifyCli::API::APIRequestServerError
      # * All other codes will raise ShopifyCli::API::APIRequestUnexpectedError
      #
      # #### Returns
      #
      # * `resp` - graphql response data hash. This can be a different shape for every query.
      #
      # #### Example
      #
      #   ShopifyCli::PartnersAPI.query(@ctx, 'all_organizations')
      #
      def query(ctx, query_name, **variables)
        authenticated_req(ctx) do
          api_client(ctx).query(query_name, variables: variables)
        end
      end

      private

      def authenticated_req(ctx)
        yield
      rescue API::APIRequestUnauthorizedError
        authenticate(ctx)
        retry
      rescue API::APIRequestNotFoundError
        ctx.puts(ctx.message('core.partners_api.error.account_not_found', ShopifyCli::TOOL_NAME))
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
        return '271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6' if ENV[LOCAL_DEBUG].nil?
        'df89d73339ac3c6c5f0a98d9ca93260763e384d51d6038da129889c308973978'
      end

      def cli_id
        return 'fbdb2649-e327-4907-8f67-908d24cfd7e3' if ENV[LOCAL_DEBUG].nil?
        'e5380e02-312a-7408-5718-e07017e9cf52'
      end

      def auth_endpoint
        return 'https://accounts.shopify.com' if ENV[LOCAL_DEBUG].nil?
        'https://identity.myshopify.io'
      end

      def endpoint
        return 'https://partners.shopify.com' if ENV[LOCAL_DEBUG].nil?
        'https://partners.myshopify.io/'
      end
    end

    def auth_headers(token)
      { Authorization: "Bearer #{token}" }
    end
  end
end
