# frozen_string_literal: true

require "byebug"
module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          METADATA_FILE = "build/metadata.json"

          def self.for(ctx, language, script_name)
            task_runner = {
              "assemblyscript" => AssemblyScriptTaskRunner,
              "typescript" => TypeScriptTaskRunner,
            }
            raise Errors::TaskRunnerNotFoundError unless task_runner[language]
            task_runner[language].new(ctx, script_name)
          end

          attr_reader :ctx, :script_name

          def initialize(ctx, script_name)
            @ctx = ctx
            @script_name = script_name
          end

          def build
            raise NotImplementedError
          end

          def compiled_type
            raise NotImplementedError
          end

          def install_dependencies
            raise NotImplementedError
          end

          def check_system_dependencies!
            required_tool_versions.each { |tool| check_tool_version!(tool[:tool_name], tool[:min_version]) }
          end

          def install_dependencies
            check_system_dependencies!
            output, status = ctx.capture2e(self.class::INSTALL_COMMAND)
            raise Errors::DependencyInstallationError, output unless status.success?
          end

          def metadata
            unless @ctx.file_exist?(METADATA_FILE)
              msg = @ctx.message("script.error.metadata_not_found_cause", METADATA_FILE)
              raise Domain::Errors::MetadataNotFoundError, msg
            end

            raw_contents = File.read(METADATA_FILE)
            Domain::Metadata.create_from_json(@ctx, raw_contents)
          end

          def project_dependencies_installed?
            raise NotImplementedError
          end

          protected

          def check_tool_version!(tool, min_required_version)
            output = tool_version_output(tool, min_required_version)

            require "semantic/semantic"
            version = ::Semantic::Version.new(output.gsub(/^v/, ""))
            unless version >= ::Semantic::Version.new(min_required_version)
              raise Errors::MissingDependencyVersionError.new(tool, output.strip, min_required_version)
            end
          end

          def compile
            raise NotImplementedError
          end

          def bytecode
            raise NotImplementedError
          end
        end
      end
    end
  end
end
