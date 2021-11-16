# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          def self.for(ctx, language, script_name)
            task_runner = {
              "assemblyscript" => AssemblyScriptTaskRunner,
              "typescript" => TypeScriptTaskRunner,
            }
            raise Errors::TaskRunnerNotFoundError unless task_runner[language]
            task_runner[language].new(ctx, script_name)
          end

          def check_system_dependencies!
            raise NotImplementedError
          end

          protected

          def check_tool_version!(tool, min_required_version)
            output, status = @ctx.capture2e(tool, "--version")
            unless status.success?
              raise Errors::NoDependencyInstalledError.new(tool, min_required_version)
            end

            require "semantic/semantic"
            version = ::Semantic::Version.new(output.gsub(/^v/, ""))
            unless version >= ::Semantic::Version.new(min_required_version)
              raise Errors::MissingDependencyVersionError.new(tool, output.strip, min_required_version)
            end
          end
        end
      end
    end
  end
end
