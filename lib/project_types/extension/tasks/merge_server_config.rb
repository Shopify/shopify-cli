# frozen_string_literal: true
require "shopify_cli"
require "yaml"

module Extension
  module Tasks
    class MergeServerConfig < ShopifyCLI::Task
      class << self
        def call(context:, file_name:, resource_url:, tunnel_url:, type:)
          config = YAML.load_file(file_name)
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
            type: type
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
