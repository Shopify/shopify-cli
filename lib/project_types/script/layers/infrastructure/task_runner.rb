# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class TaskRunner
        TASK_RUNNERS = {
          "ts" => Infrastructure::AssemblyScriptTaskRunner,
        }

        def self.for(ctx, script)
          raise Errors::TaskRunnerNotFoundError unless TASK_RUNNERS[script.language]
          TASK_RUNNERS[script.language].new(ctx, script)
        end
      end
    end
  end
end
