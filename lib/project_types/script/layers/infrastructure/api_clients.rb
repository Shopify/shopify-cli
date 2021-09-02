module Script
  module Layers
    module Infrastructure
      class ApiClients
        def self.default_client(ctx, api_key)
          if ENV["BYPASS_PARTNERS_PROXY"]
            ScriptServiceApiClient.new(ctx, api_key)
          else
            PartnersProxyApiClient.new(ctx, api_key)
          end
        end

        class ScriptServiceApiClient
          LOCAL_INSTANCE_URL = "https://script-service.myshopify.io"

          def initialize(ctx, api_key)
            instance_url = script_service_url
            @api = ShopifyCli::API.new(
              ctx: ctx,
              url: "#{instance_url}/graphql",
              token: { "APP_KEY" => api_key }.compact.to_json,
              auth_header: "X-Shopify-Authenticated-Tokens",
              api_key: api_key
            )
          end

          def query(query_name, variables: {})
            @api.query(query_name, variables: variables)
          end

          private

          def script_service_url
            if ::ShopifyCli::Environment.use_spin_partners_instance?
              "https://script-service.#{::ShopifyCli::Environment.spin_url}"
            else
              LOCAL_INSTANCE_URL
            end
          end
        end
        private_constant(:ScriptServiceApiClient)

        class PartnersProxyApiClient
          def initialize(ctx, api_key)
            @ctx = ctx
            @api_key = api_key
          end

          def query(query_name, variables: {})
            response = ShimAPI.query(@ctx, query_name, api_key: @api_key, variables: variables.to_json)
            raise_if_graphql_failed(response)
            JSON.parse(response["data"]["scriptServiceProxy"])
          end

          def raise_if_graphql_failed(response)
            raise Errors::EmptyResponseError if response.nil?

            return unless response.key?("errors")
            case error_code(response["errors"])
            when "forbidden"
              raise Errors::ForbiddenError
            when "forbidden_on_shop"
              raise Errors::ShopAuthenticationError
            when "app_not_installed_on_shop"
              raise Errors::AppNotInstalledError
            else
              raise Errors::GraphqlError, response["errors"]
            end
          end

          def error_code(errors)
            errors.map do |e|
              code = e.dig("extensions", "code")
              return code if code
            end
          end

          class ShimAPI < ShopifyCli::PartnersAPI
            def query(query_name, variables: {})
              variables[:query] = load_query(query_name)
              super("script_service_proxy", variables: variables)
            end
          end
          private_constant(:ShimAPI)
        end
        private_constant(:PartnersProxyApiClient)
      end
    end
  end
end
