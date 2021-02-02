# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class PushPackageRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def create_push_package(script, script_content, compiled_type, metadata)
          build_file_path = file_path(script.name, compiled_type)
          write_to_path(build_file_path, script_content)

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            metadata,
          )
        end

        def get_push_package(script, compiled_type, metadata)
          build_file_path = file_path(script.name, compiled_type)

          raise Domain::PushPackageNotFoundError unless ctx.file_exist?(build_file_path)

          script_content = File.read(build_file_path)

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            metadata,
          )
        end

        private

        def write_to_path(path, content)
          ctx.mkdir_p(File.dirname(path))
          ctx.write(path, content)
        end

        def file_path(script_name, compiled_type)
          "#{ScriptProject.current.directory}/build/#{script_name}.#{compiled_type}"
        end
      end
    end
  end
end
