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

        BOOTSTRAP_SRC = "npx --no-install shopify-scripts-bootstrap src %{src_base}"
        BOOTSTRAP_TEST = "npx --no-install shopify-scripts-bootstrap test %{test_base}"
        SOURCE_DIR = "src"
        TEST_DIR = "test"
        LANGUAGE = "ts"

        def setup_dependencies
          write_npmrc
          write_package_json
        end

        def bootstrap
          create_src_folder
          create_test_folder
        end

        private

        def create_src_folder
          ctx.mkdir_p(src_base)
          out, status = ctx.capture2e(format(BOOTSTRAP_SRC, src_base: src_base))
          raise Domain::Errors::ServiceFailureError, out unless status.success?

          write_tsconfig_file(SOURCE_DIR, ".")
        end

        def create_test_folder
          ctx.mkdir_p(test_base)
          out, status = ctx.capture2e(format(BOOTSTRAP_TEST, test_base: test_base))
          raise Domain::Errors::ServiceFailureError, out unless status.success?

          copy_template_file(test_base, 'as-pect.config.js')
          copy_template_file(test_base, 'as-pect.d.ts')
          write_tsconfig_file(TEST_DIR, "../#{SOURCE_DIR}")
        end

        def test_base
          "#{path_to_project}/#{TEST_DIR}"
        end

        def src_base
          "#{path_to_project}/#{SOURCE_DIR}"
        end

        def copy_template_file(destination, name)
          template_file = Project.project_filepath("templates/#{LANGUAGE}/#{name}")
          ctx.cp(template_file, "#{destination}/#{name}")
        end

        def write_npmrc
          ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', '@shopify:registry', 'https://registry.npmjs.com'
          )
          ctx.system(
            'npm', '--userconfig', './.npmrc', 'config', 'set', 'engine-strict', 'true'
          )
        end

        def write_tsconfig_file(dir, path_to_source)
          AssemblyScriptTsConfig
            .new(dir_to_write_in: dir)
            .with_extends_assemblyscript_config(relative_path_to_node_modules: ".")
            .with_module_resolution_paths(paths: { "*": ["#{path_to_source}/*.ts"] })
            .write
        end

        def write_package_json
          package_json = <<~HERE
            {
              "name": "#{script_name}",
              "version": "1.0.0",
              "devDependencies": {
                "@shopify/scripts-sdk-as": "#{extension_point.sdks[:ts].sdk_version}",
                "@shopify/scripts-toolchain-as": "#{extension_point.sdks[:ts].toolchain_version}",
                "#{extension_point.sdks[:ts].package}": "#{extension_point.sdks[:ts].version}",
                "@as-pect/cli": "4.0.0",
                "as-wasi": "^0.2.0",
                "assemblyscript": "^0.12.0"
              },
              "scripts": {
                "test": "asp --config test/as-pect.config.js --summary --verbose"
              },
              "engines": {
                "node": ">=14.5"
              }
            }
          HERE

          ctx.write("package.json", package_json)
        end
      end
    end
  end
end
