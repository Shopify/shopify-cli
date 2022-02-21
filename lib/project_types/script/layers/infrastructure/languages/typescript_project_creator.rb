# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TypeScriptProjectCreator < ProjectCreator
          def self.config_file
            "package.json"
          end

          def setup_dependencies
            task_runner = Infrastructure::Languages::TypeScriptTaskRunner.new(ctx)
            task_runner.set_npm_config

            super

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
