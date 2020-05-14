# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class DeployPackageRepository
        def create_deploy_package(script, script_content, schema, compiled_type)
          build_file_path = file_path(script.name, compiled_type)
          write_to_path(build_file_path, script_content)
          write_to_path(schema_path, schema)

          Domain::DeployPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            schema
          )
        end

        def get_deploy_package(script, compiled_type)
          build_file_path = file_path(script.name, compiled_type)

          raise Domain::DeployPackageNotFoundError unless File.exist?(build_file_path)

          script_content = File.read(build_file_path)
          schema = File.exist?(schema_path) ? File.read(schema_path) : ''

          Domain::DeployPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            schema
          )
        end

        private

        def write_to_path(path, content)
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, content)
        end

        def file_path(script_name, compiled_type)
          "#{ScriptProject.current.directory}/build/#{script_name}.#{compiled_type}"
        end

        def schema_path
          "#{ScriptProject.current.directory}/build/schema"
        end
      end
    end
  end
end
