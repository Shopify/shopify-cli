# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class PushPackageRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context

        def get_push_package(script_project:, metadata:, library:)
          build_file_path = file_path(script_project.id)
          raise Domain::Errors::PushPackageNotFoundError unless ctx.file_exist?(build_file_path)

          script_content = ctx.binread(build_file_path)
          Domain::PushPackage.new(
            id: build_file_path,
            uuid: script_project.uuid,
            extension_point_type: script_project.extension_point_type,
            title: script_project.title,
            description: script_project.description,
            script_content: script_content,
            metadata: metadata,
            script_config: script_project.script_config,
            library: library
          )
        end

        private

        def file_path(path_to_script)
          "#{path_to_script}/build/index.wasm"
        end
      end
    end
  end
end
