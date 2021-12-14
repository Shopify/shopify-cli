# frozen_string_literal: true

module Script
    module Loaders
      module Project
        def self.load(directory:, api_key:, uuid:, api_secret:)
          env_overrides = {
            "SHOPIFY_API_KEY" => api_key,
            "SHOPIFY_API_SECRET" => api_secret,
            "UUID" => uuid
          }.compact
          env = begin
            ShopifyCLI::Resources::EnvFile.read(directory, overrides: env_overrides)
          rescue Errno::ENOENT
            ShopifyCLI::Resources::EnvFile.from_hash(env_overrides)
          end
          project = ShopifyCLI::Project.at(directory)
          project.env = env
          project
        end
      end
    end
  end