module Script
  module Layers
    module Infrastructure
      class ServiceLocator
        def self.api_client(ctx:, api_key:)
          if ENV["BYPASS_PARTNERS_PROXY"]
            ApiClients::ScriptServiceApiClient.new(ctx, api_key)
          else
            ApiClients::PartnersProxyApiClient.new(ctx, api_key)
          end
        end

        def self.script_service(ctx:, api_key:)
          client = api_client(ctx: ctx, api_key: api_key)
          ScriptService.new(client: client, api_key: api_key)
        end
      end
    end
  end
end
