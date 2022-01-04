# typed: ignore
# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator < ProjectCreator
          MIN_NODE_VERSION = "14.5.0" # kept because task_runner uses this
          NPM_SET_REGISTRY_COMMAND = "npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com"
          NPM_SET_ENGINE_STRICT_COMMAND = "npm --userconfig ./.npmrc config set engine-strict true"

          def self.config_file
            "package.json"
          end

          def setup_dependencies
            super
            command_runner.call(NPM_SET_REGISTRY_COMMAND)
            command_runner.call(NPM_SET_ENGINE_STRICT_COMMAND)
          end
        end
      end
    end
  end
end
