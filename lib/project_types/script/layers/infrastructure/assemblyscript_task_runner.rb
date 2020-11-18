# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTaskRunner
        BYTECODE_FILE = "%{name}.wasm"
        SCRIPT_SDK_BUILD = "npm run build"

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
          return false unless ctx.dir_exist?("node_modules")
          check_if_ep_dependencies_up_to_date!
          true
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
          check_compilation_dependencies!

          out, status = ctx.capture2e(SCRIPT_SDK_BUILD)
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def check_compilation_dependencies!
          pkg = JSON.parse(File.read('../package.json'))
          build_script = pkg.dig('scripts', 'build')

          raise Errors::UnmetCompilationDepdencyError,
            unmet_compilation_dependency_error_message(header: "Build script not found") if build_script.nil?

          unless build_script.start_with?("npx shopify-scripts")
            raise Errors::UnmetCompilationDepdencyError,
              unmet_compilation_dependency_error_message(header: "Invalid build script")
          end
        end

        def unmet_compilation_dependency_error_message(header:)
          <<~MSG
            #{header}
            The package.json should contain a script named build, which
            should rely on @shopify/scripts-toolchain-as to compile to
            WebAssembly.

            Example:

            "build": "npx shopify-scripts-toolchain-as build --src src/script.ts --binary #{script_name}.wasm -- --lib node_modules --optimize --use Date="
          MSG
        end

        def bytecode
          blob = "../#{format(BYTECODE_FILE, name: script_name)}"
          unless @ctx.file_exist?(blob)
            raise Errors::UnmetCompilationDepdencyError,
              <<~MSG
                No WebAssembly binary found. Make sure that your build npm script
                outputs the generated binary in the root of the directory. 
                The generated binary should match the script name: <script_name>.wasm
              MSG
          end

          contents = File.read(blob)
          @ctx.rm(blob)

          contents
        end

        def check_if_ep_dependencies_up_to_date!
          return true if ENV['SHOPIFY_CLI_SCRIPTS_IGNORE_OUTDATED']

          # ignore exit code since it will not be 0 unless every package is up to date which they probably won't be
          out, _ = ctx.capture2e("npm", "outdated", "--json", "--depth", "0")
          parsed_outdated_check = JSON.parse(out)
          outdated_ep_packages = parsed_outdated_check
            .select { |package_name, _| package_name.start_with?('@shopify/extension-point-as-') }
            .select { |_, version_info| !package_is_up_to_date?(version_info) }
            .keys
          raise Errors::PackagesOutdatedError.new(outdated_ep_packages),
            "NPM packages out of date: #{outdated_ep_packages.join(', ')}" unless outdated_ep_packages.empty?
        end

        def package_is_up_to_date?(version_info)
          require 'semantic/semantic'
          current_version = version_info['current']
          latest_version = version_info['latest']

          # making an assumption that the script developer knows what they're doing if they're not referencing a
          # semver version
          begin
            current_version = ::Semantic::Version.new(current_version)
            latest_version = ::Semantic::Version.new(latest_version)
          rescue ArgumentError
            return true
          end

          return false if current_version.major < latest_version.major
          return false if latest_version.major == 0 && current_version.minor < latest_version.minor
          true
        end
      end
    end
  end
end
