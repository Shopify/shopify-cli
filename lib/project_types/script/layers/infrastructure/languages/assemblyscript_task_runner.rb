# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptTaskRunner < TaskRunner
          BYTECODE_FILE = "build/script.wasm"
          SCRIPT_SDK_BUILD = "npm run build"
          MIN_NPM_VERSION = "5.2.0"
          MIN_NODE_VERSION = "14.5.0"
<<<<<<< HEAD
<<<<<<< HEAD
=======
          REQUIRED_TOOL_VERSIONS = [
            { "tool_name": "npm", "min_version": MIN_NPM_VERSION },
            { "tool_name": "node", "min_version": MIN_NODE_VERSION },
          ]
=======
>>>>>>> 2abe8cee (refactor task_runner)
          INSTALL_COMMAND = "npm install --no-audit --no-optional --legacy-peer-deps --loglevel error"

          attr_reader :ctx, :script_name

          def initialize(ctx, script_name)
            super()
            @ctx = ctx
            @script_name = script_name
          end
>>>>>>> 6d10b0dc (refactor task_runner)

          def install_dependencies
            check_system_dependencies!

            output, status = ctx.capture2e("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            raise Errors::DependencyInstallationError, output unless status.success?
          end

          def project_dependencies_installed?
            # Assuming if node_modules folder exist at root of script folder, all deps are installed
            ctx.dir_exist?("node_modules")
          end

          def check_system_dependencies!
            check_tool_version!("npm", MIN_NPM_VERSION)
            check_tool_version!("node", MIN_NODE_VERSION)
          end

          def metadata
            unless @ctx.file_exist?(METADATA_FILE)
              msg = @ctx.message("script.error.metadata_not_found_cause", METADATA_FILE)
              raise Domain::Errors::MetadataNotFoundError, msg
            end

            raw_contents = File.read(METADATA_FILE)
            Domain::Metadata.create_from_json(@ctx, raw_contents)
          end

          def library_version(library_name)
            output = JSON.parse(CommandRunner.new(ctx: ctx).call("npm -s list --json"))
            library_version_from_npm_list(output, library_name)
          rescue Errors::SystemCallFailureError => error
            library_version_from_npm_list_error_output(error, library_name)
          end

          protected

          def compiled_type
            "wasm"
          end

          def required_tool_versions
            [
              { "tool_name": "npm", "min_version": MIN_NPM_VERSION },
              { "tool_name": "node", "min_version": MIN_NODE_VERSION },
            ]
          end

          def tool_version_output(tool, min_required_version)
            output, status = @ctx.capture2e(tool, "--version")
            unless status.success?
              raise Errors::NoDependencyInstalledError.new(tool, min_required_version)
            end

            output
          end

          private

          def compile
            check_compilation_dependencies!
            CommandRunner.new(ctx: ctx).call(SCRIPT_SDK_BUILD)
          end

          def bytecode
            raise Errors::WebAssemblyBinaryNotFoundError unless ctx.file_exist?(BYTECODE_FILE)

            contents = ctx.binread(BYTECODE_FILE)
            ctx.rm(BYTECODE_FILE)

            contents
          end

          def library_version_from_npm_list_error_output(error, library_name)
            # npm list can return a failure status code, even when returning the correct data.
            # This causes the CommandRunner to throw a SystemCallFailure error that contains the data.
            # In here, we check that the output contains `npm list`'s structure and extract the version.
            output = JSON.parse(error.out)
            raise error unless output.key?("dependencies")

            library_version_from_npm_list(output, library_name)
          rescue JSON::ParserError
            raise error
          end

          def library_version_from_npm_list(output, library_name)
            output.dig("dependencies", library_name, "version").tap do |version|
              raise Errors::APILibraryNotFoundError, library_name unless version
            end
          end

          def check_compilation_dependencies!
            pkg = JSON.parse(File.read("package.json"))
            build_script = pkg.dig("scripts", "build")

            raise Errors::BuildScriptNotFoundError,
              "Build script not found" if build_script.nil?

            unless build_script.start_with?("shopify-scripts")
              raise Errors::InvalidBuildScriptError, "Invalid build script"
            end
          end
        end
      end
    end
  end
end
