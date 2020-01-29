# frozen_string_literal: true

require "tmpdir"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRepository < Repository
        def create_script(language, extension_point, script_name)
          source_file_path = src_code_file(language, script_name)

          FileUtils.mkdir_p(src_base(script_name))
          File.write(source_file_path, extension_point.example_scripts[language])

          write_sdk(
            extension_point.type,
            script_name,
            language,
            extension_point.sdk_types
          )

          Domain::Script.new(
            script_name,
            extension_point,
            language
          )
        end

        def get_script(ctx, language, extension_point_type, script_name)
          source_file_path = src_code_file(language, script_name)
          unless File.exist?(source_file_path)
            raise Domain::ScriptNotFoundError.new(extension_point_type, source_file_path)
          end

          extension_point = extension_point_repo(ctx).get_extension_point(extension_point_type)

          Domain::Script.new(script_name, extension_point, language)
        end

        def with_script_build_context(script)
          prev_dir = format(FOLDER_PATH_TEMPLATE, script_name: script.name)
          temp_dir = "#{prev_dir}/temp"
          FileUtils.mkdir_p(temp_dir)
          Dir.chdir(temp_dir)
          FileUtils.cp_r("#{File.dirname(file_path(script))}/.", ".")
          yield

        ensure
          Dir.chdir(prev_dir)
        end

        def with_script_context(script_name)
          prev_dir = Dir.pwd
          script_dir = format(FOLDER_PATH_TEMPLATE, script_name: script_name)
          Dir.chdir(script_dir)
          yield

        ensure
          Dir.chdir(prev_dir)
        end

        private

        def write_sdk(extension_point_type, script_name, language, sdk_types)
          return unless language == "ts"

          FileUtils.cp_r(runtime_types, src_base(script_name))
          File.write(sdk_types_file(extension_point_type, script_name, language), sdk_types)
        end

        def extension_point_repo(ctx)
          ExtensionPointRepository.new(ScriptService.new(ctx: ctx))
        end

        def src_base(script_name)
          "#{format(FOLDER_PATH_TEMPLATE, script_name: script_name)}/src"
        end

        def runtime_types
          "#{INSTALLATION_BASE_PATH}/sdk/shopify_runtime_types.ts"
        end

        def src_code_file(language, script_name)
          "#{src_base(script_name)}/#{script_name}.#{language}"
        end

        def schema_file(extension_point_type, script_name)
          "#{src_base(script_name)}/#{extension_point_type}.schema"
        end

        def sdk_types_file(extension_point_type, script_name, language)
          "#{src_base(script_name)}/#{extension_point_type}.#{language}"
        end

        def file_path(script)
          src_code_file(script.language, script.name)
        end
      end
    end
  end
end
