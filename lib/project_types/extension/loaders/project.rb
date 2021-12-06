# frozen_string_literal: true

module Extension
  module Loaders
    module Project
      def self.load(directory:, api_key:, registration_id:, api_secret:)
        env_overrides = {
          "SHOPIFY_API_KEY" => api_key,
          "SHOPIFY_API_SECRET" => api_secret,
          "EXTENSION_ID" => registration_id
        }.compact
        env = begin
          ShopifyCLI::Resources::EnvFile.read(directory, overrides: env_overrides)
        rescue Errno::ENOENT
          nil
        end
        ExtensionProject.at(directory, env: env)
      end
    end
  end
end
