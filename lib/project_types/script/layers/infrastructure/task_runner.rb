# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class TaskRunner
        TASK_RUNNERS = {
          "ts" => Infrastructure::AssemblyScriptTaskRunner,
        }

        def self.for(ctx, language)
          raise Errors::TaskRunnerNotFoundError unless TASK_RUNNERS[language]
          TASK_RUNNERS[language].new(ctx)
        end
      end
    end
  end
end
