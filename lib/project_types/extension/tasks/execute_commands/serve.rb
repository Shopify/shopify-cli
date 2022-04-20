# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module ExecuteCommands
      class Serve < Base
        prepend OutdatedExtensionDetection

        property! :config_file_path, accepts: String
        property  :port, accepts: Integer, default: ShopifyCLI::Constants::Extension::DEFAULT_PORT
        property  :resource_url, accepts: String
        property! :tunnel_url, accepts: String

        def call
          ShopifyCLI::Result
            .call(&method(:merge_server_config))
            .then { |server_config| Models::DevelopmentServer.new.serve(context, server_config) }
        end

        private

        def merge_server_config
          Tasks::MergeServerConfig.call(
            context: context,
            file_path: config_file_path,
            port: port,
            resource_url: resource_url,
            tunnel_url: tunnel_url,
            type: type
          )
        end
      end
    end
  end
end
