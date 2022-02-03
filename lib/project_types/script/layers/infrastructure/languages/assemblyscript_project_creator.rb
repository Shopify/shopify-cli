# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator < ProjectCreator
          def self.config_file
            "package.json"
          end

          def setup_dependencies
            task_runner = Infrastructure::Languages::AssemblyScriptTaskRunner.new(ctx)
            task_runner.ensure_environment

            super
            task_runner.set_npm_config
          end
        end
      end
    end
  end
end
