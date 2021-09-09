module Script
  module Layers
    module Infrastructure
      class ServiceLocator
        def self.script_service(ctx:, api_key:)
          client = ApiClients.default_client(ctx, api_key)
          ScriptService.new(client: client, api_key: api_key)
        end
      end
    end
  end
end
