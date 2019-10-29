require "pathname"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class ConfigurationRepository < Repository
        BASE_DIR_NAME = "configuration"
        SCHEMA_FILE_NAME = "configuration.schema"
        GLUE_CODE_FILE_NAME = "configuration.ts"
        private_constant :BASE_DIR_NAME, :SCHEMA_FILE_NAME, :GLUE_CODE_FILE_NAME

        def create_configuration(extension_point, script_name)
          root = root(extension_point.type, script_name)
          FileUtils.mkdir_p(root)
          FileUtils.cp_r(config_template, root)

          Domain::Configuration.new(root, SCHEMA_FILE_NAME, File.read("#{root}/#{SCHEMA_FILE_NAME}"), nil)
        end

        def update_configuration(configuration)
          Pathname.new("#{config_dir_path(configuration)}/#{GLUE_CODE_FILE_NAME}").write(configuration.glue_code)
        end

        def get_configuration(extension_point_type, script_name)
          root = root(extension_point_type, script_name)
          schema_source_file = "#{root}/#{SCHEMA_FILE_NAME}"

          unless File.exist?(schema_source_file)
            raise Domain::ConfigurationFileNotFoundError.new(script_name, root)
          end

          schema_glue_code_file = "#{root}/#{GLUE_CODE_FILE_NAME}"
          schema_glue_code = File.exist?(schema_glue_code_file) ? File.read(schema_glue_code_file) : nil

          Domain::Configuration.new(root, SCHEMA_FILE_NAME, File.read(schema_source_file), schema_glue_code)
        end

        private

        def root(extension_point_type, script_name)
          "#{SOURCE_PATH}/#{extension_point_type}/#{script_name}/#{BASE_DIR_NAME}"
        end

        def config_template
          "#{INSTALLATION_BASE_PATH}/templates/configuration/configuration.schema"
        end

        def config_dir_path(configuration)
          configuration.id
        end
      end
    end
  end
end
