# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptProjectCreator
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context
        property! :extension_point, accepts: Domain::ExtensionPoint
        property! :script_name, accepts: String
        property! :path_to_project, accepts: String

        BOOTSTRAP = "npx --no-install shopify-scripts-toolchain-as bootstrap --from %{extension_point} --dest %{base}"
        MIN_NODE_VERSION = "14.5.0"

        def setup_dependencies
          write_npmrc
          write_package_json
        end

        def bootstrap
          type = extension_point.type.gsub('_', '-')
          out, status = ctx.capture2e(format(BOOTSTRAP, extension_point: type, base: path_to_project))
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        private

        def write_npmrc
          ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com'
          )
          ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', 'engine-strict', 'true'
          )
        end

        def extension_point_version
          out, status = ctx.capture2e("npm show #{extension_point.sdks[:ts].package} version --json")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
          JSON.parse(out)
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "#{extension_point.sdks[:ts].sdk_version}",
                "@shopify/scripts-toolchain-as": "#{extension_point.sdks[:ts].toolchain_version}",
                "#{extension_point.sdks[:ts].package}": "^#{extension_point_version}",
                "@as-pect/cli": "4.0.0",
                "as-wasi": "^0.2.1",
                "assemblyscript": "^0.14.0"
              },
              "scripts": {
                "test": "asp --summary --verbose",
                "build": "shopify-scripts-toolchain-as build --src src/script.ts --binary build/#{script_name}.wasm --metadata build/metadata.json -- --lib node_modules --optimize --use Date="
              },
              "engines": {
                "node": ">=#{MIN_NODE_VERSION}"
              }
            }
          HERE
          ctx.write("package.json", package_json)
        end
      end
    end
  end
end
