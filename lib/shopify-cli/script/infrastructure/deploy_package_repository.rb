# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class DeployPackageRepository < Repository
        def create_deploy_package(script, script_content)
          compiled_type = Infrastructure::ScriptBuilder.for(script).compiled_type
          build_file_path = file_path(script.extension_point.type, script.name, compiled_type)
          write_to_path(
            build_file_path,
            script_content
          )
          Domain::DeployPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type
          )
        end

        def get_deploy_package(language, extension_point_type, script_name)
          script = ScriptRepository.new.get_script(language, extension_point_type, script_name)
          compiled_type = Infrastructure::ScriptBuilder.for(script).compiled_type

          id = file_path(extension_point_type, script_name, compiled_type)
          raise Domain::DeployPackageNotFoundError.new(extension_point_type, script_name) unless File.exist?(id)

          Domain::DeployPackage.new(id, script, File.read(id), compiled_type)
        end

        private

        def write_to_path(path, content)
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
        end

        def file_path(extension_point_type, script_name, content_type)
          "#{src_base(extension_point_type, script_name)}/build/#{script_name}.#{content_type}"
        end

        def src_base(extension_point_type, script_name)
          "#{SOURCE_PATH}/#{extension_point_type}/#{script_name}"
        end
      end
    end
  end
end
