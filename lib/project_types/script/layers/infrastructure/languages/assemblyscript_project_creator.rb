# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator < ProjectCreator
          MIN_NODE_VERSION = "14.5.0" # kept because task_runner uses this

          def setup_dependencies
            super
            write_npmrc
          end

          def write_npmrc
            command_runner.call("npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com")
            command_runner.call("npm --userconfig ./.npmrc config set engine-strict true")
          end

        end
      end
    end
  end
end
