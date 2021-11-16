# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TypeScriptProjectCreator < ProjectCreator
          NPM_SET_REGISTRY_COMMAND = "npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com"
          NPM_SET_ENGINE_STRICT_COMMAND = "npm --userconfig ./.npmrc config set engine-strict true"

          def self.config_file
            "package.json"
          end

          def setup_dependencies
            super
            command_runner.call(NPM_SET_REGISTRY_COMMAND)
            command_runner.call(NPM_SET_ENGINE_STRICT_COMMAND)

            if ctx.file_exist?("yarn.lock")
              ctx.rm("yarn.lock")
            end

            if ctx.file_exist?("package-lock.json")
              ctx.rm("package-lock.json")
            end
          end
        end
      end
    end
  end
end
