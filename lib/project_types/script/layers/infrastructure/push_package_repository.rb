# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class PushPackageRepository
        def create_push_package(script, script_content, compiled_type)
          build_file_path = file_path(script.name, compiled_type)
          write_to_path(build_file_path, script_content)

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
          )
        end

        def get_push_package(script, compiled_type)
          build_file_path = file_path(script.name, compiled_type)

          raise Domain::PushPackageNotFoundError unless File.exist?(build_file_path)

          script_content = File.read(build_file_path)

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
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
      end
    end
  end
end
