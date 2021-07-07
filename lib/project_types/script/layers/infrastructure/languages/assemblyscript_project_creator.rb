# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class AssemblyScriptProjectCreator
          include SmartProperties
          property! :ctx, accepts: ShopifyCli::Context
          property! :extension_point, accepts: Domain::ExtensionPoint
          property! :script_name, accepts: String
          property! :path_to_project, accepts: String

          BUILD = "shopify-scripts-toolchain-as build --src src/shopify_main.ts " \
          "--binary build/script.wasm --metadata build/metadata.json"
          MIN_NODE_VERSION = "14.5.0" # kept because task_runner uses this
          ASC_ARGS = "-- --lib node_modules --optimize --use Date="

          ORIGIN_BRANCH = "master"

          def setup_dependencies
            # sparse checkout actions
            git_init
            setup_remote
            setup_sparse_checkout
            pull
            clean

            # TODO: files that should be in the repo, but arent yet
            write_npmrc
            write_package_json
          end

          def bootstrap
          end

          def sparse_checkout_set_path
            type = extension_point.dasherize_type
            domain = extension_point.domain

            if domain.nil?
              "packages/default/extension-point-as-#{type}/assembly/sample"
            else
              "packages/#{domain}/samples/#{type}"
            end
          end

          private

          def git_init
            command_runner.call("git init")
          end

          def setup_remote
            repo = extension_point.sdks.assemblyscript.repo
            command_runner.call("git remote add -f origin #{repo}")
          end

          def setup_sparse_checkout
            command_runner.call("git config core.sparsecheckout true")
            command_runner.call("git sparse-checkout set #{sparse_checkout_set_path}")
          end

          def pull
            command_runner.call("git pull origin #{ORIGIN_BRANCH}")
          end

          def clean
            source = File.join(path_to_project, sparse_checkout_set_path)
            FileUtils.copy_entry(source, path_to_project)
            ctx.rm_rf("packages")
            ctx.rm_rf(".git")
          end

          def command_runner
            @command_runner ||= CommandRunner.new(ctx: ctx)
          end

          def write_npmrc
            command_runner.call("npm --userconfig ./.npmrc config set @shopify:registry https://registry.npmjs.com")
            command_runner.call("npm --userconfig ./.npmrc config set engine-strict true")
          end

          def extension_point_version
            return extension_point.sdks.assemblyscript.version if extension_point.sdks.assemblyscript.versioned?

            out = command_runner.call("npm show #{extension_point.sdks.assemblyscript.package} version --json")
            "^#{JSON.parse(out)}"
          end

          def write_package_json
            package_json = <<~HERE
              {
                "name": "#{script_name}",
                "version": "1.0.0",
                "devDependencies": {
                  "@shopify/scripts-sdk-as": "#{extension_point.sdks.assemblyscript.sdk_version}",
                  "@shopify/scripts-toolchain-as": "#{extension_point.sdks.assemblyscript.toolchain_version}",
                  "#{extension_point.sdks.assemblyscript.package}": "#{extension_point_version}",
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

          def build_command
            domain = extension_point.domain

            if domain.nil?
              "#{BUILD} #{ASC_ARGS}"
            else
              "#{BUILD} --domain #{domain} --ep #{extension_point.dasherize_type} #{ASC_ARGS}"
            end
          end
        end
      end
    end
  end
end
