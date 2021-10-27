# frozen_string_literal: true
require "shopify_cli"
require "yaml"

module Extension
  module Tasks
    class LoadServerConfig < ShopifyCLI::Task
      include SmartProperties

      class << self
        def call(file_name:, type:)
          config = YAML.load_file(file_name)
          project = ExtensionProject.current
          Tasks::Converters::ServerConfigConverter.from_hash(
            hash: config,
            type: type,
            registration_uuid: project.registration_uuid
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
