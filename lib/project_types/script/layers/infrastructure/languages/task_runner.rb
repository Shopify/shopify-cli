# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          TASK_RUNNERS = {
            "assemblyscript" => AssemblyScriptTaskRunner,
            "rust" => RustTaskRunner,
            "typescript" => TypeScriptTaskRunner,
          }

          def self.for(ctx, language, script_name)
            raise Errors::TaskRunnerNotFoundError unless TASK_RUNNERS[language]
            TASK_RUNNERS[language].new(ctx, script_name)
          end
        end
      end
    end
  end
end
