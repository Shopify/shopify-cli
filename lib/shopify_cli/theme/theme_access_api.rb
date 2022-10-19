# frozen_string_literal: true

require "shopify_cli"

module ShopifyCLI
  module Theme
    ##
    # ShopifyCLI::ThemeAccessAPI is a wrapper to use Shopify Theme Access API, which allows using passwords
    # generated from Shopify Theme Access app to access the Shopify Admin API (for theme operations)
    #
    class ThemeAccessAPI < API
      BASE_URL = "theme-kit-access.shopifyapps.com"

      class << self
        ##
        # #### Parameters
        # - `ctx`: running context from your command
        # - `shop`: shop domain string for shop whose admin you are calling
        # - `path`: path string (excluding prefixes and API version) for specific JSON that you are requesting
        #     ex. "data.json" instead of "/admin/api/unstable/data.json"
        # - `body`: data string for corresponding REST request types
        # - `method`: REST request string for the type of request; if nil, will perform GET request
        # - `api_version`: an api version string to specify version. Default value: unstable
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
        #   ThemeAccessAPI.rest_request(@ctx, shop: 'shop.myshopify.com', path: 'data.json')
        #
        def rest_request(ctx, shop:, path:, query: nil, body: nil, method: "GET", api_version: "unstable")
          client = api_client(ctx, api_version, shop, path: path)
          url = build_url(api_version, path, query)
          client.request(url: url, body: body, headers: headers(shop), method: method)
        rescue ShopifyCLI::API::APIRequestForbiddenError,
               ShopifyCLI::API::APIRequestUnauthorizedError
          ctx.abort(ctx.message("core.api.error.theme_access_invalid_password"))
        end

        def get_shop_or_abort(ctx)
          env_store = Environment.store
          return env_store unless env_store.nil?
          ctx.abort(
            ctx.message("core.api.error.theme_access_no_store")
          )
        end

        private

        def build_url(api_version, path, query = nil)
          URI::HTTPS.build(
            host: BASE_URL,
            path: "/cli/admin/api/#{api_version}/#{path}",
            query: query
          ).to_s
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
          "X-Shopify-Access-Token" => token,
        }
      end
    end
  end
end
