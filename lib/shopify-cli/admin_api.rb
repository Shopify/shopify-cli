require 'shopify_cli'

module ShopifyCli
  class AdminAPI < API
    autoload :PopulateResourceCommand, 'shopify-cli/admin_api/populate_resource_command'

    class << self
      def query(ctx, body, api_version: nil, shop: nil, **variables)
        @shop = shop
        authenticated_req(ctx) do
          api_client(ctx, api_version).query(body, variables: variables)
        end
      end

      private

      def authenticated_req(ctx)
        yield
      rescue API::APIRequestUnauthorizedError
        Tasks::AuthenticateShopify.call(ctx, shop: @shop)
        retry
      end

      def api_client(ctx, api_version)
        new(
          ctx: ctx,
          auth_header: 'X-Shopify-Access-Token',
          token: Helpers::AccessToken.read(ctx),
          url: "#{endpoint}/#{fetch_api_version(ctx, api_version)}/graphql.json",
        )
      end

      def fetch_api_version(ctx, api_version)
        return api_version unless api_version.nil?
        client = new(
          ctx: ctx,
          auth_header: 'X-Shopify-Access-Token',
          token: Helpers::AccessToken.read(ctx),
          url: "#{endpoint}/unstable/graphql.json",
        )
        versions = client.query('api_versions')['data']['publicApiVersions']
        latest = versions.find { |version| version['displayName'].include?('Latest') }
        latest['handle']
      end

      def endpoint
        "https://#{@shop || Project.current.env.shop}/admin/api"
      end
    end
  end
end
