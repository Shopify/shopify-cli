# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module ExecuteCommands
      class Build < Base
        prepend OutdatedExtensionDetection

        property! :config_file_path, accepts: String

        def call
          ShopifyCLI::Result
            .call(&method(:merge_server_config))
            .then { |server_config| Models::DevelopmentServer.new.build(server_config) }
        end

        private

        def merge_server_config
          Tasks::MergeServerConfig.call(
            context: context,
            file_path: config_file_path,
            type: type
          )
        end
      end
    end
  end
end
