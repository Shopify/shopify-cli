# frozen_string_literal: true

module TestHelpers
  class FakePushPackageRepository
    def initialize
      @cache = {}
    end

    def create_push_package(
      script_project:,
      script_content:,
      compiled_type:,
      metadata:,
      library:
    )
      id = id(script_project.script_name, compiled_type)
      @cache[id] = Script::Layers::Domain::PushPackage.new(
        id: id,
        uuid: script_project.uuid,
        extension_point_type: script_project.extension_point_type,
        script_content: script_content,
        compiled_type: compiled_type,
        metadata: metadata,
        script_json: script_project.script_json,
        library: library
      )
    end

    def get_push_package(script_project:, compiled_type:, metadata:, library:)
      _ = metadata
      _ = library
      id = id(script_project.script_name, compiled_type)
      if @cache.key?(id)
        @cache[id]
      else
        raise Script::Layers::Domain::Errors::PushPackageNotFoundError
      end
    end

    private

    def id(script_name, compiled_type)
      "#{script_name}.#{compiled_type}"
    end
  end
end
