# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          attr_reader :ctx

          def self.for(ctx, language)
            task_runners = {
              "typescript" => TypeScriptTaskRunner,
              "wasm" => WasmTaskRunner,
            }

            task_runner = task_runners[language] || TaskRunner

            task_runner.new(ctx)
          end

          def initialize(ctx)
            @ctx = ctx
          end

          def build; end

          def dependencies_installed?
            true
          end

          def install_dependencies; end

          # this should be removed soon
          def metadata_file_location
            "metadata.json"
          end

          # this should be removed soon
          def library_version(_library_name)
            "1.0.0"
          end
        end
      end
    end
  end
end
