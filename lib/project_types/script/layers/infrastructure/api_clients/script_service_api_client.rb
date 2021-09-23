module Script
  module Layers
    module Infrastructure
      module ApiClients
        class ScriptServiceApiClient
          LOCAL_INSTANCE_URL = "https://script-service.myshopify.io"

          def initialize(ctx, api_key)
            instance_url = script_service_url
            @api = ShopifyCLI::API.new(
              ctx: ctx,
              url: "#{instance_url}/graphql",
              token: { "APP_KEY" => api_key }.compact.to_json,
              auth_header: "X-Shopify-Authenticated-Tokens"
            )
          end

          def query(query_name, variables: {})
            @api.query(query_name, variables: variables)
          end

          private

          def script_service_url
            if ::ShopifyCLI::Environment.use_spin?
              "https://script-service.#{::ShopifyCLI::Environment.spin_url}"
            else
              LOCAL_INSTANCE_URL
            end
          end
        end
      end
    end
  end
end
