# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          attr_reader :ctx, :script_name

          def self.for(ctx, language, script_name)
            task_runners = {
              "assemblyscript" => AssemblyScriptTaskRunner,
              "typescript" => TypeScriptTaskRunner,
              "wasm" => WasmTaskRunner,
            }

            raise Errors::TaskRunnerNotFoundError unless task_runners[language]
            task_runners[language].new(ctx, script_name)
          end

          def initialize(ctx, script_name)
            @ctx = ctx
            @script_name = script_name
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
