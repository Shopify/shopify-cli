# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptDependencyManager
        def initialize(ctx, language, extension_point, script_name)
          @ctx = ctx
          @language = language
          @script_name = script_name
          @extension_point = extension_point
        end

        def bootstrap
          write_npmrc
          write_package_json
        end

        def installed?
          # Assuming if node_modules folder exist at root of script folder, all deps are installed
          Dir.exist?("node_modules")
        end

        def install
          check_node_version!

          output, status = @ctx.capture2e("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          raise Errors::DependencyInstallError, output unless status.success?
        end

        private

        def check_node_version!
          output, status = @ctx.capture2e("node", "--version")
          raise Errors::DependencyInstallError, output unless status.success?

          version = Semantic::Version.new(output[1..-1])
          unless version >= Semantic::Version.new("12.16.0")
            raise Errors::DependencyInstallError, "Node version must be >= v12.16.0 Current version: #{output}."
          end
        end

        def write_npmrc
          @ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com'
          )
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{@script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "#{@extension_point.sdks[:ts].sdk_version}",
                "@shopify/scripts-toolchain-as": "#{@extension_point.sdks[:ts].toolchain_version}",
                "#{@extension_point.sdks[:ts].package}": "#{@extension_point.sdks[:ts].version}",
                "@as-pect/cli": "4.0.0",
                "as-wasi": "^0.0.1",
                "assemblyscript": "^0.12.0"
              },
              "scripts": {
                "test": "asp --config test/as-pect.config.js --summary --verbose"
              }
            }
          HERE

          File.write("package.json", package_json)
        end
      end
    end
  end
end
