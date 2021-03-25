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
        BUILD = "shopify-scripts-toolchain-as build --src src/shopify_main.ts --binary build/%{script_name}.wasm --metadata build/metadata.json"
        MIN_NODE_VERSION = "14.5.0"
        ASC_ARGS = "-- --lib node_modules --optimize --use Date="

        def setup_dependencies
          write_npmrc
          write_package_json
        end

        def bootstrap
          out, status = ctx.capture2e(bootstap_command)
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        private

        def write_npmrc
          ctx.system(
            "npm", "--userconfig", "./.npmrc", "config", "set", "@shopify:registry", "https://registry.npmjs.com"
          )
          ctx.system(
            "npm", "--userconfig", "./.npmrc", "config", "set", "engine-strict", "true"
          )
        end

        def extension_point_version
          out, status = ctx.capture2e("npm show #{extension_point.sdks.assemblyscript.package} version --json")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
          JSON.parse(out)
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "#{extension_point.sdks.assemblyscript.sdk_version}",
                "@shopify/scripts-toolchain-as": "#{extension_point.sdks.assemblyscript.toolchain_version}",
                "#{extension_point.sdks.assemblyscript.package}": "^#{extension_point_version}",
                "@as-pect/cli": "^6.0.0",
                "assemblyscript": "^0.18.13"
              },
              "scripts": {
                "test": "asp --summary --verbose",
                "build": "#{build_command}"
              },
              "engines": {
                "node": ">=#{MIN_NODE_VERSION}"
              }
            }
          HERE
          ctx.write("package.json", package_json)
        end

        def bootstap_command
          type = extension_point.dasherize_type
          base_command = format(BOOTSTRAP, extension_point: type, base: path_to_project)
          domain = extension_point.domain

          if domain.nil?
            base_command
          else
            "#{base_command} --domain #{domain}"
          end
        end

        def build_command
          type = extension_point.dasherize_type
          base_command = format(BUILD, script_name: script_name)
          domain = extension_point.domain

          if domain.nil?
            "#{base_command} #{ASC_ARGS}"
          else
            "#{base_command} --domain #{domain} --ep #{type} #{ASC_ARGS}"
          end
        end
      end
    end
  end
end
