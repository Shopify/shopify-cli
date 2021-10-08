
# frozen_string_literal: true

require 'byebug'
module Script
  module Layers
    module Infrastructure
      module Languages
        class TaskRunner
          BYTECODE_FILE = "build/%{name}.wasm"
          METADATA_FILE = "build/metadata.json"
          SCRIPT_SDK_BUILD = "npm run build"
          MIN_NPM_VERSION = "5.2.0"

          def self.for(ctx, language, script_name)
            task_runner = {
              "assemblyscript" => AssemblyScriptTaskRunner,
              "typescript" => TypeScriptTaskRunner,
            }
            raise Errors::TaskRunnerNotFoundError unless task_runner[language]
            task_runner[language].new(ctx, script_name)
          end

          def compiled_type
            "wasm"
          end

          def project_dependencies_installed?
            # Assuming if node_modules folder exist at root of script folder, all deps are installed
            ctx.dir_exist?("node_modules")
          end

          def metadata
            unless @ctx.file_exist?(METADATA_FILE)
              msg = @ctx.message("script.error.metadata_not_found_cause", METADATA_FILE)
              raise Domain::Errors::MetadataNotFoundError, msg
            end

            raw_contents = File.read(METADATA_FILE)
            Domain::Metadata.create_from_json(@ctx, raw_contents)
          end

          def install_dependencies
            self.check_system_dependencies!

            output, status = ctx.capture2e("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            raise Errors::DependencyInstallationError, output unless status.success?
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
