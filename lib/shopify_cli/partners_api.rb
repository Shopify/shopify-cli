require "shopify_cli"

module ShopifyCLI
  ##
  # ShopifyCLI::PartnersAPI provides easy access to the partners dashboard CLI
  # schema.
  #
  class PartnersAPI < API
    autoload :Organizations, "shopify_cli/partners_api/organizations"
    autoload :AppExtensions, "shopify_cli/partners_api/app_extensions"

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
      #   ShopifyCLI::PartnersAPI.query(@ctx, 'all_organizations')
      #
      def query(ctx, query_name, **variables)
        CLI::Kit::Util.begin do
          api_client(ctx).query(query_name, variables: variables)
        end.retry_after(
          API::APIRequestUnauthorizedError,
          retries: 1,
          only: -> { !IdentityAuth::EnvAuthToken.partners_token_present? }
        ) do
          ShopifyCLI::IdentityAuth.new(ctx: ctx).reauthenticate
        end
      rescue API::APIRequestUnauthorizedError => e
        if (request_info = auth_failure_info(ctx, e))
          ctx.puts(ctx.message("core.api.error.failed_auth_debugging", request_info))
        end
        ctx.abort(ctx.message("core.api.error.failed_auth"))
      rescue API::APIRequestNotFoundError
        ctx.puts(ctx.message("core.partners_api.error.account_not_found", ShopifyCLI::TOOL_NAME))
      end

      def partners_url_for(organization_id, api_client_id)
        if ShopifyCLI::Shopifolk.acting_as_shopify_organization?
          organization_id = "internal"
        end
        "https://#{Environment.partners_domain}/#{organization_id}/apps/#{api_client_id}"
      end

      private

      def api_client(ctx)
        identity_auth = ShopifyCLI::IdentityAuth.new(ctx: ctx)
        new(
          ctx: ctx,
          token: identity_auth.fetch_or_auth_partners_token,
          url: "https://#{Environment.partners_domain}/api/cli/graphql",
        )
      end

      def auth_failure_info(ctx, error)
        if error.response
          headers = %w(www-authenticate x-request-id)
          request_info = headers.map { |h| "#{h}: #{error.response[h]}" if error.response.key?(h) }.join("\n")
          ctx.debug("Full headers: #{error.response.each_header.to_h}")
          request_info
        end
      rescue => e
        ctx.debug("Couldn't fetch auth failure information from #{error}: #{e}")
      end
    end

    def auth_headers(token)
      { Authorization: "Bearer #{token}" }
    end
  end
end
