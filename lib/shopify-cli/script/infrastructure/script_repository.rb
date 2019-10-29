# frozen_string_literal: true

require "tmpdir"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ScriptRepository < Repository
        def create_script(language, extension_point, configuration, script_name)
          source_file_path = src_code_file(extension_point.type, language, script_name)

          FileUtils.cp_r(runtime_types, src_base(extension_point.type, script_name))
          File.write(source_file_path, extension_point.example_script)

          write_schema_and_sdk_types(
            extension_point.type,
            script_name,
            extension_point.schema,
            language,
            extension_point.sdk_types
          )

          Domain::Script.new(
            script_name,
            extension_point,
            configuration,
            language,
            extension_point.schema
          )
        end

        def get_script(language, extension_point_type, script_name)
          source_file_path = src_code_file(extension_point_type, language, script_name)
          schema_file_path = schema_file(extension_point_type, script_name)
          unless File.exist?(source_file_path) && File.exist?(schema_file_path)
            raise Domain::ScriptNotFoundError.new(extension_point_type, source_file_path)
          end

          extension_point = extension_point_repo.get_extension_point(extension_point_type)
          configuration = configuration_repo.get_configuration(extension_point_type, script_name)
          schema = File.read(schema_file_path)

          Domain::Script.new(script_name, extension_point, configuration, language, schema)
        end

        def with_script_context(script)
          Dir.mktmpdir do |tmp|
            Dir.chdir(tmp) do
              FileUtils.cp_r("#{File.dirname(file_path(script))}/.", ".")
              yield
            end
          end
        end

        private

        def write_schema_and_sdk_types(extension_point_type, script_name, schema, language, sdk_types)
          FileUtils.mkdir_p(types_path(extension_point_type, script_name))
          File.write(schema_file(extension_point_type, script_name), schema)
          File.write(sdk_types_file(extension_point_type, script_name, language), sdk_types)
        end

        def extension_point_repo
          ExtensionPointRepository.new(ScriptService.new)
        end

        def configuration_repo
          ConfigurationRepository.new
        end

        def src_base(extension_point_type, script_name)
          "#{SOURCE_PATH}/#{extension_point_type}/#{script_name}"
        end

        def types_path(extension_point_type, script_name)
          "#{src_base(extension_point_type, script_name)}/types"
        end

        def runtime_types
          "#{INSTALLATION_BASE_PATH}/sdk/shopify_runtime_types.ts"
        end

        def src_code_file(extension_point_type, language, script_name)
          "#{src_base(extension_point_type, script_name)}/#{script_name}.#{language}"
        end

        def schema_file(extension_point_type, script_name)
          "#{types_path(extension_point_type, script_name)}/#{extension_point_type}.schema"
        end

        def sdk_types_file(extension_point_type, script_name, language)
          "#{types_path(extension_point_type, script_name)}/#{extension_point_type}.#{language}"
        end

        def file_path(script)
          src_code_file(script.extension_point.type, script.language, script.name)
        end
      end
    end
  end
end
