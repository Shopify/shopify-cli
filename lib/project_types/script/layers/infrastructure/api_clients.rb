module Script
  module Layers
    module Infrastructure
      class ApiClients
        def self.default_client(ctx, api_key)
          PartnersProxyApiClient.new(ctx, api_key)
        end

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
