# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context
          property! :script_api, accepts: Domain::ScriptApi
          property! :script_name, accepts: String
          property! :path_to_project, accepts: String

          BOOTSTRAP = "npx --no-install shopify-scripts-toolchain-as bootstrap --from %{script_api} --dest %{base}"
          BUILD = "shopify-scripts-toolchain-as build --src src/shopify_main.ts " \
          "--binary build/script.wasm --metadata build/metadata.json"
          MIN_NODE_VERSION = "14.5.0"
          ASC_ARGS = "-- --lib node_modules --optimize --use Date="

          def setup_dependencies
            write_npmrc
            write_package_json
          end

          def bootstrap
            command_runner.call(bootstap_command)
          end

          private

          def command_runner
            @command_runner ||= CommandRunner.new(ctx: ctx)
          end

          def write_npmrc
            command_runner.call("npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com")
            command_runner.call("npm --userconfig ./.npmrc config set engine-strict true")
          end

          def script_api_version
            return script_api.sdks.assemblyscript.version if script_api.sdks.assemblyscript.versioned?

            out = command_runner.call("npm show #{script_api.sdks.assemblyscript.package} version --json")
            "^#{JSON.parse(out)}"
          end

          def write_package_json
            package_json = <<~HERE
              {
                "name": "#{script_name}",
                "version": "1.0.0",
                "devDependencies": {
                  "@shopify/scripts-sdk-as": "#{script_api.sdks.assemblyscript.sdk_version}",
                  "@shopify/scripts-toolchain-as": "#{script_api.sdks.assemblyscript.toolchain_version}",
                  "#{script_api.sdks.assemblyscript.package}": "#{script_api_version}",
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
            type = script_api.dasherize_type
            base_command = format(BOOTSTRAP, script_api: type, base: path_to_project)
            domain = script_api.domain

            if domain.nil?
              base_command
            else
              "#{base_command} --domain #{domain}"
            end
          end

          def build_command
            type = script_api.dasherize_type
            domain = script_api.domain

            if domain.nil?
              "#{BUILD} #{ASC_ARGS}"
            else
              "#{BUILD} --domain #{domain} --ep #{type} #{ASC_ARGS}"
            end
          end
        end
      end
    end
  end
end
