module Script
  module Layers
    module Infrastructure
      module Languages
        module ToolVersionChecker
          def check_tool_versions(tools)
            tools.each do |tool, properties|
              env_version = case tool
              when "node"
                ShopifyCLI::Environment.node_version
              when "npm"
                ShopifyCLI::Environment.npm_version
              end

              next if env_version >= ::Semantic::Version.new(properties["minimum_version"])
              raise Errors::DependencyInstallError, "Your environment #{tool} version, #{env_version},"\
                " is too low. It must be greater than #{properties["minimum_version"]}."
            end
          end
        end
      end
    end
  end
end
