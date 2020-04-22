require 'shopify_cli'

module ShopifyCli
  class AdminAPI < API
    autoload :PopulateResourceCommand, 'shopify-cli/admin_api/populate_resource_command'
    autoload :Schema, 'shopify-cli/admin_api/schema'

    class << self
      def query(ctx, body, api_version: nil, shop: nil, **variables)
        shop = shop || Project.current.env.shop
        authenticated_req(ctx, shop) do
          api_client(ctx, api_version, shop).query(body, variables: variables)
        end
      end

      private

      def authenticated_req(ctx, shop)
        yield
      rescue API::APIRequestUnauthorizedError
        authenticate(ctx, shop)
        retry
      end

      def authenticate(ctx, shop)
        env = Project.current.env
        ShopifyCli::OAuth.new(
          ctx: ctx,
          service: 'admin',
          client_id: env.api_key,
          secret: env.secret,
          scopes: env.scopes,
          token_path: "/access_token",
          options: { 'grant_options[]' => 'per user' },
        ).authenticate("https://#{shop}/admin/oauth")
      end

      def api_client(ctx, api_version, shop)
        new(
          ctx: ctx,
          auth_header: 'X-Shopify-Access-Token',
          token: admin_access_token(ctx, shop),
          url: "https://#{shop}/admin/api/#{fetch_api_version(ctx, api_version, shop)}/graphql.json",
        )
      end

      def admin_access_token(ctx, shop)
        ShopifyCli::DB.get(:admin_access_token) do
          authenticate(ctx, shop)
          ShopifyCli::DB.get(:admin_access_token)
        end
      end

      def fetch_api_version(ctx, api_version, shop)
        return api_version unless api_version.nil?
        client = new(
          ctx: ctx,
          auth_header: 'X-Shopify-Access-Token',
          token: admin_access_token(ctx, shop),
          url: "https://#{shop}/admin/api/unstable/graphql.json",
        )
        versions = client.query('api_versions')['data']['publicApiVersions']
        latest = versions.find { |version| version['displayName'].include?('Latest') }
        latest['handle']
      end
    end
  end
end
