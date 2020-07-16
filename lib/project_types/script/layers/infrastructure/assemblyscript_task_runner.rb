# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTaskRunner
        BYTECODE_FILE = "%{name}.wasm"
        SCRIPT_SDK_BUILD = "npx --no-install shopify-scripts-build --src=../%{source} --binary=#{BYTECODE_FILE} "\
                           "-- --lib=../node_modules --validate --optimize"

        attr_reader :ctx, :script_name, :script_source_file

        def initialize(ctx, script_name, script_source_file)
          @ctx = ctx
          @script_name = script_name
          @script_source_file = script_source_file
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
          ctx.dir_exist?("node_modules")
        end

        private

        def check_node_version!
          output, status = @ctx.capture2e("node", "--version")
          raise Errors::DependencyInstallError, output unless status.success?

          require 'semantic/semantic'
          version = ::Semantic::Version.new(output[1..-1])
          unless version >= ::Semantic::Version.new("12.16.0")
            raise Errors::DependencyInstallError, "Node version must be >= v12.16.0. Current version: #{output.strip}."
          end
        end

        def compile
          out, status = ctx.capture2e(format(SCRIPT_SDK_BUILD, source: script_source_file, name: script_name))
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def bytecode
          File.read(format(BYTECODE_FILE, name: script_name))
        end
      end
    end
  end
end
