# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TypeScriptTaskRunner < TaskRunner
          include ToolVersionChecker
          TOOLS = {
            "node" => {
              "minimum_version" => "14.15.0",
            },
            "npm" => {
              "minimum_version" => "5.2.0",
            },
          }

          BYTECODE_FILE = "build/index.wasm"
          METADATA_FILE = "build/metadata.json"
          SCRIPT_SDK_BUILD = "npm run build"
          GEN_METADATA = "npm run gen-metadata"
          NPM_SET_REGISTRY_COMMAND = "npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com"
          NPM_SET_ENGINE_STRICT_COMMAND = "npm --userconfig ./.npmrc config set engine-strict true"

          def build
            compile
            bytecode
          end

          def install_dependencies
            ensure_environment
            output, status = ctx.capture2e("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            raise Errors::DependencyInstallError, output unless status.success?
          end

          def dependencies_installed?
            # Assuming if node_modules folder exist at root of script folder, all deps are installed
            ctx.dir_exist?("node_modules")
          end

          def metadata_file_location
            METADATA_FILE
          end

          def library_version(library_name)
            ensure_environment
            output = JSON.parse(CommandRunner.new(ctx: ctx).call("npm -s list --json"))
            library_version_from_npm_list(output, library_name)
          rescue Errors::SystemCallFailureError => error
            library_version_from_npm_list_error_output(error, library_name)
          end

          def set_npm_config
            ensure_environment
            CommandRunner.new(ctx: ctx).call(NPM_SET_REGISTRY_COMMAND)
            CommandRunner.new(ctx: ctx).call(NPM_SET_ENGINE_STRICT_COMMAND)
          end

          def ensure_environment
            check_tool_versions(TOOLS)
          end

          private

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

          def compile
            check_compilation_dependencies!
            CommandRunner.new(ctx: ctx).call(SCRIPT_SDK_BUILD)
            CommandRunner.new(ctx: ctx).call(GEN_METADATA)
          end

          def check_compilation_dependencies!
            pkg = JSON.parse(File.read("package.json"))
            build_script = pkg.dig("scripts", "build")

            raise Errors::BuildScriptNotFoundError,
              "Build script not found" if build_script.nil?
          end

          def bytecode
            raise Errors::WebAssemblyBinaryNotFoundError unless ctx.file_exist?(BYTECODE_FILE)

            contents = ctx.binread(BYTECODE_FILE)
            ctx.rm(BYTECODE_FILE)

            contents
          end
        end
      end
    end
  end
end
