# frozen_string_literal: true

module TestHelpers
  class FakePushPackageRepository
    def initialize
      @cache = {}
    end

    def create_push_package(
      script_project:,
      script_content:,
      metadata:,
      library:
    )
      id = id(script_project.script_name)
      @cache[id] = Script::Layers::Domain::PushPackage.new(
        id: id,
        uuid: script_project.uuid,
        extension_point_type: script_project.extension_point_type,
        script_content: script_content,
        metadata: metadata,
        script_config: script_project.script_config,
        library: library
      )
    end

    def get_push_package(script_project:, metadata:, library:)
      _ = metadata
      _ = library
      id = id(script_project.script_name)
      if @cache.key?(id)
        @cache[id]
      else
        raise Script::Layers::Domain::Errors::PushPackageNotFoundError
      end
    end

    private

    def id(script_name)
      "#{script_name}.wasm"
    end
  end
end
