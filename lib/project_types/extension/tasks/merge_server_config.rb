# frozen_string_literal: true
require "shopify_cli"
require "pathname"

module Extension
  module Tasks
    class MergeServerConfig
      include SmartProperties

      property! :context, accepts: ShopifyCLI::Context
      property! :file_path, accepts: ->(path) { Pathname(path).yield_self(&:absolute?) }
      property! :port, accepts: Integer, default: ShopifyCLI::Constants::Extension::DEFAULT_PORT
      property  :resource_url, accepts: String
      property  :tunnel_url, accepts: String
      property! :type, accepts: Models::DevelopmentServerRequirements::SUPPORTED_EXTENSION_TYPES

      def self.call(*args)
        new(*args).call
      end

      def call
        config = YAML.load_file(file_path) if File.file?(file_path)
        config ||= {}

        project = ExtensionProject.current
        Tasks::ConvertServerConfig.call(
          api_key: project.env.api_key,
          context: context,
          hash: config,
          registration_uuid: project.registration_uuid,
          resource_url: resource_url || project.resource_url,
          store: project.env.shop || "",
          title: project.title,
          tunnel_url: tunnel_url,
          type: type,
          port: port,
          metafields: config["metafields"]
        )
      rescue Psych::SyntaxError => e
        raise(
          ShopifyCLI::Abort,
          ShopifyCLI::Context.message("core.yaml.error.invalid", file_name, e.message)
        )
      end
    end
  end
end
