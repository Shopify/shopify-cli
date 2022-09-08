# frozen_string_literal: true

module Extension
  module Loaders
    module Project
      def self.load(context:, directory:, api_key:, registration_id:, api_secret:, env: {})
        env_overrides = {
          "SHOPIFY_API_KEY" => api_key,
          "SHOPIFY_API_SECRET" => api_secret,
          "EXTENSION_ID" => registration_id,
        }.compact.merge(env)

        env_file_present = env_file_exists?(directory)
        env = if env_file_present
          ShopifyCLI::Resources::EnvFile.read(directory, overrides: env_overrides)
        else
          ShopifyCLI::Resources::EnvFile.from_hash(env_overrides)
        end
        # This is a somewhat uncomfortable hack we use because `Project::at` is
        # a global cache and we can't rely on this class loading the project
        # first. Long-term we should move away from that global cache.
        project = ExtensionProject.at(directory)
        project.env = env
        project
      rescue SmartProperties::InitializationError, SmartProperties::MissingValueError => error
        handle_error(error, context: context)
      end

      def self.handle_error(error, context:)
        if ShopifyCLI::Environment.interactive?
          properties_hash = { api_key: "SHOPIFY_API_KEY", secret: "SHOPIFY_API_SECRET" }
          missing_env_variables = error.properties.map { |p| properties_hash[p.name] }.compact.join(", ")
          message = context.message("errors.missing_env_file_variables", missing_env_variables)
          message += context.message("errors.missing_env_file_variables_solution", ShopifyCLI::TOOL_NAME)
        else
          properties_hash = { api_key: "--api-key", secret: "--api-secret" }
          missing_options = error.properties.map { |p| properties_hash[p.name] }.compact.join(", ")
          message = context.message("errors.missing_push_options_ci", missing_options)
          message += context.message("errors.missing_push_options_ci_solution", ShopifyCLI::TOOL_NAME)
        end
        raise ShopifyCLI::Abort,
          message
      end

      def self.env_file_exists?(directory)
        File.exist?(ShopifyCLI::Resources::EnvFile.path(directory))
      end
    end
  end
end
