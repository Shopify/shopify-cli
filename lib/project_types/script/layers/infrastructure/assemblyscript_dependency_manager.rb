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
          output, status = @ctx.capture2e("npm", "install", "--no-audit", "--no-optional", "--loglevel error")
          raise Errors::DependencyInstallError, output unless status.success?
        end

        private

        def write_npmrc
          @ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com'
          )
          @ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', 'engine-strict', 'true'
          )
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{@script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "#{@extension_point.sdks[:ts].sdk_version}",
                "#{@extension_point.sdks[:ts].package}": "#{@extension_point.sdks[:ts].version}",
                "@as-pect/cli": "3.1.4",
                "yargs": "10.0.0",
                "as-wasi": "^0.0.1",
                "assemblyscript": "^0.9.4",
                "ts-node": "^8.5.4",
                "typescript": "^3.7.3"
              },
              "scripts": {
                "test": "asp --config test/as-pect.config.js --summary --verbose"
              },
              "engines": {
                "node": ">=12.16"
              }
            }
          HERE

          File.write("package.json", package_json)
        end
      end
    end
  end
end
