# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          attr_reader :ctx

          def self.for(ctx, language)
            task_runners = {
              "assemblyscript" => AssemblyScriptTaskRunner,
              "typescript" => TypeScriptTaskRunner,
              "wasm" => WasmTaskRunner,
            }

            raise Errors::TaskRunnerNotFoundError unless task_runners[language]
            task_runners[language].new(ctx)
          end

          def initialize(ctx)
            @ctx = ctx
          end

          def build
            raise NotImplementedError
          end

          def dependencies_installed?
            raise NotImplementedError
          end

          def install_dependencies
            raise NotImplementedError
          end

          def metadata_file_location
            raise NotImplementedError
          end

          def library_version(_library_name)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
