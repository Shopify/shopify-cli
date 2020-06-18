# frozen_string_literal: true

require 'pathname'

module Script
  module Layers
    module Infrastructure
      class TestSuiteRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        ASPECT_DTS_FILENAME = "as-pect.d.ts"
        ASPECT_DTS_FILE_CONTENTS = "/// <reference types=\"@as-pect/assembly/types/as-pect\" />"
        BOOTSTRAP_TEST = "npx --no-install shopify-scripts-bootstrap test %{test_base}"

        def create_test_suite(script)
          # Remove this once we have a test suite for js
          return unless script.language == "ts"

          ctx.mkdir_p(test_base)
          ctx.cp(aspect_config_template(script.language), "#{test_base}/as-pect.config.js")
          out, status = CLI::Kit::System.capture2e(format(BOOTSTRAP_TEST, test_base: test_base))
          raise Domain::Errors::ServiceFailureError, out unless status.success?

          write_tsconfig_file
          write_aspect_type_definitions_file
        end

        private

        def test_dir
          "test"
        end

        def test_base
          "#{ScriptProject.current.directory}/#{test_dir}"
        end

        def aspect_config_template(language)
          Project.project_filepath("templates/#{language}/as-pect.config.js")
        end

        def write_tsconfig_file
          AssemblyScriptTsConfig
            .new(dir_to_write_in: test_dir)
            .with_extends_assemblyscript_config(relative_path_to_node_modules: ".")
            .with_module_resolution_paths(paths: { "*": ["#{relative_path_to_source_dir}/*.ts"] })
            .write
        end

        def relative_path_to_source_dir
          src_path_from_root = ScriptRepository.new(ctx: ctx).relative_path_to_src
          Pathname.new(src_path_from_root).relative_path_from(test_dir)
        end

        def write_aspect_type_definitions_file
          File.write("#{test_base}/#{ASPECT_DTS_FILENAME}", ASPECT_DTS_FILE_CONTENTS)
        end
      end
    end
  end
end
