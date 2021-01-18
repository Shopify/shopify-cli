# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class Metadata
        attr_reader :schema_major_version, :schema_minor_version

        def initialize(schema_major_version, schema_minor_version)
          @schema_major_version = schema_major_version
          @schema_minor_version = schema_minor_version
        end

        class << self
          def create_from_json(metadata_json)
            metadata_hash = JSON.load(metadata_json)
            schema_versions = metadata_hash["schemaVersions"]
            # FIXME use proper error types
            raise "Metadata is missing schemaVersions" if schema_versions.nil?

            # Scripts may be attached to more than one EP in the future but not right now
            raise "Metadata schemaVersions should have one key" unless schema_versions.count == 1

            _, version = schema_versions.first
            schema_major_version = version["major"]
            schema_minor_version = version["minor"]
            raise "Metadata schema version is missing major key" if schema_major_version.nil?

            is_prerelease = schema_major_version == "prerelease"
            raise "Metadata schema version is missing minor key" if schema_minor_version.nil? && !is_prerelease

            Metadata.new(schema_major_version, schema_minor_version)
          end
        end
      end
    end
  end
end