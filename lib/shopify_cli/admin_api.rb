require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::AdminAPI wraps our graphql functionality with authentication so that
  # these concerns are taken care of.
  #
  class AdminAPI < API
    autoload :PopulateResourceCommand, "shopify_cli/admin_api/populate_resource_command"
    autoload :Schema, "shopify_cli/admin_api/schema"

    class << self
      ##
      # issues a graphql query or mutation to the Shopify Admin API. It loads a graphql
      # query from a file so that you do not need to use large unwieldy query strings.
      #
      # #### Parameters
      # - `ctx`: running context from your command
      # - `query_name`: name of the query you want to use, loaded from the `lib/graphql` directory.
      # - `api_version`: an api version string to specify version. If no version is supplied then unstable will be used
      # - `shop`: shop domain string for which shop that you are calling the admin
      #   API on. If not supplied, then it will be fetched from the `.env` file
      # - `**variable`: a hash of variables to be supplied to the query ro mutation
      #
      # #### Raises
      #
      # * http 404 will raise a ShopifyCLI::API::APIRequestNotFoundError
      # * http 400..499 will raise a ShopifyCLI::API::APIRequestClientError
      # * http 500..599 will raise a ShopifyCLI::API::APIRequestServerError
      # * All other codes will raise ShopifyCLI::API::APIRequestUnexpectedError
      #
      # #### Returns
      #
      # * `resp` - graphql response data hash. This can be a different shape for every query.
      #
      # #### Example
      #
      #   ShopifyCLI::AdminAPI.query(@ctx, 'all_organizations')
      #
      def query(ctx, query_name, shop:, api_version: nil, **variables)
        CLI::Kit::Util.begin do
          api_client(ctx, api_version, shop).query(query_name, variables: variables)
        end.retry_after(API::APIRequestUnauthorizedError, retries: 1) do
          ShopifyCLI::IdentityAuth.new(ctx: ctx).reauthenticate
        end
      rescue API::APIRequestUnauthorizedError
        ctx.abort(ctx.message("core.api.error.failed_auth"))
      rescue API::APIRequestForbiddenError
        ctx.abort(ctx.message("core.api.error.forbidden", ShopifyCLI::TOOL_NAME))
      end

      ##
      #
      #
      #
      # #### Parameters
      # - `ctx`: running context from your command
      # - `shop`: shop domain string for shop whose admin you are calling
      # - `path`: path string (excluding prefixes and API version) for specific JSON that you are requesting
      #     ex. "data.json" instead of "/admin/api/unstable/data.json"
      # - `body`: data string for corresponding REST request types
      # - `method`: REST request string for the type of request; if nil, will perform GET request
      # - `api_version`: API version string to specify version; if nil, latest will be used
      # - `token`: shop password string for authentication to shop
      #
      # #### Raises
      #
      # * http 404 will raise a ShopifyCLI::API::APIRequestNotFoundError
      # * http 400..499 will raise a ShopifyCLI::API::APIRequestClientError
      # * http 500..599 will raise a ShopifyCLI::API::APIRequestServerError
      # * All other codes will raise ShopifyCLI::API::APIRequestUnexpectedError
      #
      # #### Returns
      #
      # * `resp` - JSON response array
      #
      # #### Example
      #
      #   ShopifyCLI::AdminAPI.rest_request(@ctx,
      #                                     shop: 'shop.myshopify.com',
      #                                     path: 'data.json',
      #                                     token: 'password')
      #
      def rest_request(ctx, shop:, path:, query: nil, body: nil, method: "GET", api_version: nil, token: nil)
        CLI::Kit::Util.begin do
          ShopifyCLI::DB.set(shopify_exchange_token: token) unless token.nil?
          url = URI::HTTPS.build(
            host: shop,
            path: "/admin/api/#{fetch_api_version(ctx, api_version, shop)}/#{path}",
            query: query,
          )
          resp = api_client(ctx, api_version, shop, path: path).request(url: url.to_s, body: body, method: method)
          ShopifyCLI::DB.set(shopify_exchange_token: nil) unless token.nil?
          resp
        end.retry_after(API::APIRequestUnauthorizedError) do
          ShopifyCLI::IdentityAuth.new(ctx: ctx).reauthenticate
        end
      end

      def get_shop_or_abort(ctx)
        env_store = Environment.store
        return env_store unless env_store.nil?
        ctx.abort(
          ctx.message("core.populate.error.no_shop", ShopifyCLI::TOOL_NAME)
        ) unless ShopifyCLI::DB.exists?(:shop)
        ShopifyCLI::DB.get(:shop)
      end

      private

      def authenticate(ctx, _shop)
        ShopifyCLI::IdentityAuth.new(ctx: ctx).authenticate
      end

      def api_client(ctx, api_version, shop, path: "graphql.json")
        new(
          ctx: ctx,
          token: access_token(ctx, shop),
          url: "https://#{shop}/admin/api/#{fetch_api_version(ctx, api_version, shop)}/#{path}",
        )
      end

      def access_token(ctx, shop)
        env_token = Environment.admin_auth_token
        env_token || ShopifyCLI::DB.get(:shopify_exchange_token) do
          authenticate(ctx, shop)
          ShopifyCLI::DB.get(:shopify_exchange_token)
        end
      end

      def fetch_api_version(ctx, api_version, shop)
        return api_version unless api_version.nil?
        client = new(
          ctx: ctx,
          token: access_token(ctx, shop),
          url: "https://#{shop}/admin/api/unstable/graphql.json",
        )
        CLI::Kit::Util.begin do
          versions = client.query("api_versions")["data"]["publicApiVersions"]
          # return the most recent supported version
          versions
            .select { |version| version["supported"] }
            .map { |version| version["handle"] }
            .sort
            .reverse[0]
        end.retry_after(API::APIRequestUnauthorizedError, retries: 1) do
          ShopifyCLI::IdentityAuth.new(ctx: ctx).reauthenticate
        end
      rescue API::APIRequestUnauthorizedError
        ctx.abort(ctx.message("core.api.error.failed_auth"))
      rescue API::APIRequestForbiddenError
        ctx.abort(ctx.message("core.api.error.forbidden", ShopifyCLI::TOOL_NAME))
      end
    end

    def auth_headers(token)
      {
        Authorization: "Bearer #{token}",
        "X-Shopify-Access-Token" => token,
      }
    end
  end
end
