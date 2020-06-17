# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTaskRunner
        BYTECODE_FILE = "%{name}.wasm"
        SCRIPT_SDK_BUILD = "npx --no-install shopify-scripts-build --src=../%{source} --binary=#{BYTECODE_FILE} "\
                           "-- --lib=../node_modules --validate --optimize"

        attr_reader :ctx

        def initialize(ctx)
          @ctx = ctx
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

          output, status = ctx.capture2e("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          raise Errors::DependencyInstallError, output unless status.success?
        end

        def dependencies_installed?
          # Assuming if node_modules folder exist at root of script folder, all deps are installed
          Dir.exist?("node_modules")
        end

        private

        def project
          @project ||= ScriptProject.current
        end

        def check_node_version!
          output, status = @ctx.capture2e("node", "--version")
          raise Errors::DependencyInstallError, output unless status.success?

          version = ::Semantic::Version.new(output[1..-1])
          unless version >= ::Semantic::Version.new("12.16.0")
            raise Errors::DependencyInstallError, "Node version must be >= v12.16.0. Current version: #{output.strip}."
          end
        end

        def compile
          out, status = ctx.capture2e(format(SCRIPT_SDK_BUILD, source: project.source_file, name: project.script_name))
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def bytecode
          File.read(format(BYTECODE_FILE, name: project.script_name))
        end
      end
    end
  end
end
