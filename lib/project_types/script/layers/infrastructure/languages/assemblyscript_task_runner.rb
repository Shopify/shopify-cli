# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptTaskRunner < TaskRunner
          MIN_NODE_VERSION = "14.5.0"
          REQUIRED_TOOL_VERSIONS = [
            {"tool_name": "npm", "min_version": MIN_NPM_VERSION},
            {"tool_name": "node", "min_version": MIN_NODE_VERSION}
          ]

          attr_reader :ctx, :script_name

          def initialize(ctx, script_name)
            super()
            @ctx = ctx
            @script_name = script_name
          end

          def build
            compile
            bytecode
          end

          def check_system_dependencies!
            REQUIRED_TOOL_VERSIONS.each { |tool| check_tool_version!(tool[:tool_name], tool[:min_version])}
          end

          private

          def compile
            check_compilation_dependencies!
            CommandRunner.new(ctx: ctx).call(SCRIPT_SDK_BUILD)
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

          def bytecode
            legacy_filename = format(BYTECODE_FILE, name: script_name)
            filename = format(BYTECODE_FILE, name: "script")

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
