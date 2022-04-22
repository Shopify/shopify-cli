# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module ExecuteCommands
      class Create < Base
        property!  :template, accepts: Models::ServerConfig::Development::VALID_TEMPLATES
        property!  :root_dir, accepts: String

        def call
          ShopifyCLI::Result.success(generate_config)
            .then { |server_config| Models::DevelopmentServer.new.create(server_config) }
        end

        private

        def generate_config
          extension = Models::ServerConfig::Extension.build(
            template: template,
            type: type,
            root_dir: root_dir,
          )

          Models::ServerConfig::Root.new(extensions: [extension])
        end
      end
    end
  end
end
