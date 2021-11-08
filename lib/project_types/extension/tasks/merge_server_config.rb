# frozen_string_literal: true
require "shopify_cli"
require "yaml"

module Extension
  module Tasks
    class MergeServerConfig < ShopifyCLI::Task
      include SmartProperties

      class << self
        def call(context:, file_name:, resource_url:, tunnel_url:, type:)
          config = YAML.load_file(file_name)
          project = ExtensionProject.current
          Tasks::Converters::ServerConfigConverter.from_hash(
            api_key: project.env.api_key,
            context: context,
            hash: config,
            type: type,
            registration_uuid: project.registration_uuid,
            resource_url: resource_url || project.resource_url,
            store: project.env.shop || "",
            tunnel_url: tunnel_url,
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
end
