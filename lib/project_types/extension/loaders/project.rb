# frozen_string_literal: true

module Extension
  module Loaders
    module Project
      def self.load(context:, directory:, api_key:, registration_id:, api_secret:)
        env_overrides = {
          "SHOPIFY_API_KEY" => api_key,
          "SHOPIFY_API_SECRET" => api_secret,
          "EXTENSION_ID" => registration_id
        }.compact
        env = begin
          ShopifyCLI::Resources::EnvFile.read(directory, overrides: env_overrides)
        rescue Errno::ENOENT
          ShopifyCLI::Resources::EnvFile.from_hash(env_overrides)
        end
        # This is a somewhat uncomfortable hack we use because `Project::at` is
        # a global cache and we can't rely on this class loading the project
        # first. Long-term we should move away from that global cache.
        project = ExtensionProject.at(directory)
        project.env = env
        project
      rescue SmartProperties::InitializationError, SmartProperties::MissingValueError
        context.abort(context.message("errors.missing_api_key"))
      end
    end
  end
end
