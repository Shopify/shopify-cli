require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::ThemeAccessAPI is a wrapper to use Shopify Theme Access API, which allows using passwords
  # generated from Shopify Theme Access app to access the Shopify Admin API (for theme operations)
  #
  class ThemeAccessAPI < API
    URL = "https://theme-kit-access.shopifyapps.com/cli"

    class << self
      ##
      # #### Parameters
      # - `ctx`: running context from your command
      # - `shop`: shop domain string for shop whose admin you are calling
      # - `path`: path string (excluding prefixes and API version) for specific JSON that you are requesting
      #     ex. "data.json" instead of "/admin/api/unstable/data.json"
      # - `body`: data string for corresponding REST request types
      # - `method`: REST request string for the type of request; if nil, will perform GET request
      # - `api_version`: an api version string to specify version. If no version is supplied then unstable will be used
      # - `token`: theme access app password string for authentication to shop
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
      #   ShopifyCLI::ThemeAccessAPI.rest_request(@ctx,
      #                                           shop: 'shop.myshopify.com',
      #                                           path: 'data.json',
      #                                           token: 'theme-app-password')
      #
      def rest_request(ctx, shop:, path:, body: nil, method: "GET", api_version: "unstable")
        client = api_client(ctx, api_version, shop, path: path)
        client.request(url: build_url(api_version, path), body: body, headers: headers(shop), method: method)
      end

      def get_shop_or_abort(ctx)
        env_store = Environment.store
        return env_store unless env_store.nil?
        ctx.abort(
          ctx.message("core.api.error.theme_access_no_store")
        )
      end

      private

      def build_url(api_version, path)
        "#{URL}/admin/api/#{api_version}/#{path}"
      end

      def api_client(ctx, api_version, _shop, path: "graphql.json")
        new(
          ctx: ctx,
          token: Environment.admin_auth_token,
          url: build_url(api_version, path),
        )
      end

      def headers(shop)
        {
          "X-Shopify-Shop" => shop,
        }
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
