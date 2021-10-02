# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class TypeScriptTaskRunner
          BYTECODE_FILE = "build/%{name}.wasm"
          METADATA_FILE = "build/metadata.json"
          SCRIPT_SDK_BUILD = "npm run build"
          GEN_METADATA = "npm run gen-metadata"

          attr_reader :ctx, :script_name

          def initialize(ctx, script_name)
            @ctx = ctx
            @script_name = script_name
          end

          def build
            compile
            bytecode
          end

          def compiled_type
            "wasm"
          end

          def install_dependencies
            check_node_version!

            output, status = ctx.capture2e("npm install --no-audit --no-optional --legacy-peer-deps --loglevel error")
            raise Errors::DependencyInstallError, output unless status.success?
          end

          def dependencies_installed?
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

          private

          def check_node_version!
            output, status = @ctx.capture2e("node", "--version")
            raise Errors::DependencyInstallError, output unless status.success?

            require "semantic/semantic"
            version = ::Semantic::Version.new(output[1..-1])
            unless version >= ::Semantic::Version.new(TypeScriptProjectCreator::MIN_NODE_VERSION)
              raise Errors::DependencyInstallError,
                "Node version must be >= v#{TypeScriptProjectCreator::MIN_NODE_VERSION}. "\
            "Current version: #{output.strip}."
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

            unless build_script.start_with?("javy")
              raise Errors::InvalidBuildScriptError, "Invalid build script"
            end
          end

          def bytecode
            legacy_filename = format(BYTECODE_FILE, name: script_name)
            filename = format(BYTECODE_FILE, name: "index")

            bytecode_file = if ctx.file_exist?(filename)
              filename
            elsif ctx.file_exist?(legacy_filename)
              legacy_filename
            else
              raise Errors::WebAssemblyBinaryNotFoundError
            end

            contents = ctx.binread(bytecode_file)
            ctx.rm(bytecode_file)

            contents
          end
        end
      end
    end
  end
end
