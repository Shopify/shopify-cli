# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        BOOTSTRAP_SRC = "npx --no-install shopify-scripts-bootstrap src %{src_base}"

        def create_script(language, extension_point, script_name)
          ctx.mkdir_p(src_base)
          out, status = CLI::Kit::System.capture2e(format(BOOTSTRAP_SRC, src_base: src_base))
          raise Domain::Errors::ServiceFailureError, out unless status.success?

          write_tsconfig if language == "ts"

          Domain::Script.new(
            script_id(language),
            script_name,
            extension_point.type,
            language
          )
        end

        def get_script(language, extension_point_type, script_name)
          source_file_path = src_code_file(language)
          unless File.exist?(source_file_path)
            raise Domain::Errors::ScriptNotFoundError.new(extension_point_type, source_file_path)
          end

          Domain::Script.new(script_id(language), script_name, extension_point_type, language)
        end

        def with_temp_build_context
          prev_dir = Dir.pwd
          temp_dir = "#{project_base}/temp"
          ctx.mkdir_p(temp_dir)
          ctx.chdir(temp_dir)
          ctx.cp_r("#{src_base}/.", ".")
          yield
        ensure
          ctx.chdir(prev_dir)
          ctx.rm_rf(temp_dir)
        end

        def relative_path_to_src
          "src"
        end

        private

        def write_sdk(extension_point_type, language, sdk_types)
          return unless language == "ts"
          File.write(sdk_types_file(extension_point_type, language), sdk_types)
        end

        def write_tsconfig
          AssemblyScriptTsConfig
            .new(dir_to_write_in: relative_path_to_src)
            .with_extends_assemblyscript_config(relative_path_to_node_modules: ".")
            .write
        end

        def project_base
          ScriptProject.current.directory
        end

        def src_base
          "#{project_base}/#{relative_path_to_src}"
        end

        def script_id(language)
          "#{relative_path_to_src}/#{file_name(language)}"
        end

        def src_code_file(language)
          "#{src_base}/#{file_name(language)}"
        end

        def file_name(language)
          "script.#{language}"
        end

        def sdk_types_file(extension_point_type, language)
          "#{src_base}/#{extension_point_type}.#{language}"
        end
      end
    end
  end
end
