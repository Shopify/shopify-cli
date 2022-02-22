module Script
  module Layers
    module Infrastructure
      module Languages
        class ToolVersionChecker
          class << self
            def check_node(minimum_version:)
              check_version("node", ShopifyCLI::Environment.node_version, minimum_version)
            end

            def check_npm(minimum_version:)
              check_version("npm", ShopifyCLI::Environment.npm_version, minimum_version)
            end

            private

            def check_version(tool, env_version, minimum_version)
              return if env_version >= ::Semantic::Version.new(minimum_version)
              raise Errors::InvalidEnvironmentError.new(tool, env_version, minimum_version)
            end
          end
        end
      end
    end
  end
end
