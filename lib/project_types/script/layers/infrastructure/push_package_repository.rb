# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class PushPackageRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def create_push_package(script, script_content, schema, compiled_type)
          build_file_path = file_path(script.name, compiled_type)
          write_to_path(build_file_path, script_content)
          write_to_path(schema_path, schema)

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            schema
          )
        end

        def get_push_package(script, compiled_type)
          build_file_path = file_path(script.name, compiled_type)

          raise Domain::PushPackageNotFoundError unless File.exist?(build_file_path)

          script_content = File.read(build_file_path)
          schema = File.exist?(schema_path) ? File.read(schema_path) : ''

          Domain::PushPackage.new(
            build_file_path,
            script,
            script_content,
            compiled_type,
            schema
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

        def schema_path
          "#{ScriptProject.current.directory}/build/schema"
        end
      end
    end
  end
end
