# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTaskRunner
        BYTECODE_FILE = "%{name}.wasm"
        SCRIPT_SDK_BUILD = "npx --no-install shopify-scripts-build --src=../%{source} --binary=#{BYTECODE_FILE} "\
                           "-- --lib=../node_modules --optimize --use Date="

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

        def check_if_safe_to_push!
          return true if ENV['SHOPIFY_CLI_SCRIPTS_IGNORE_OUTDATED']

          # ignore exit code since it will not be 0 unless every package is up to date which they probably won't be
          out, _ = ctx.capture2e("npm", "outdated", "--json", "--depth", "0")
          parsed_outdated_check = JSON.parse(out)
          outdated_ep_packages = parsed_outdated_check
            .select { |package_name, _| package_name.start_with?('@shopify/extension-point-as-') }
            .select { |_, version_info| !package_is_up_to_date?(version_info) }
            .keys
          raise Errors::PackagesOutdatedError.new(outdated_ep_packages),
            "The following packages must be updated before you can push: #{outdated_ep_packages.join(', ')}" unless outdated_ep_packages.empty?
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

        def package_is_up_to_date?(version_info)
          require 'semantic/semantic'
          current_version = version_info['current']
          latest_version = version_info['latest']

          # making an assumption that the script developer knows what they're doing if they're not referencing a semver version
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
