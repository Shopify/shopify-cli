# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class TaskRunner
        TASK_RUNNERS = {
          "assemblyscript" => Infrastructure::AssemblyScriptTaskRunner,
        }

        def self.for(ctx, language, script_name)
          raise Errors::TaskRunnerNotFoundError unless TASK_RUNNERS[language]
          TASK_RUNNERS[language].new(ctx, script_name)
        end
      end
    end
  end
end
