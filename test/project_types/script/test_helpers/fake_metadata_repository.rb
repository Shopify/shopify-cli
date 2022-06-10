# frozen_string_literal: true

module TestHelpers
  class FakeMetadataRepository
    def initialize
      @cache = {}
    end

    def create_metadata(file_location,
      schema_major_version = "1",
      schema_minor_version = "0")
      @cache[file_location] = Script::Layers::Domain::Metadata.new(
        schema_major_version,
        schema_minor_version,
      )
    end

    def get_metadata(file_location)
      if @cache.key?(file_location)
        @cache[file_location]
      else
        raise Domain::Errors::MetadataNotFoundError, file_location
      end
    end
  end
end
