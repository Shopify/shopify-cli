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
          def create_from_json(ctx, metadata_json)
            err_tag = nil
            metadata_hash = JSON.parse(metadata_json)

            schema_versions = metadata_hash["schemaVersions"] || {}

            version = schema_versions.values.first || {}
            schema_major_version = version["major"]
            schema_minor_version = version["minor"]

            if schema_versions.empty?
              err_tag = "script.error.metadata_schema_versions_missing"
            elsif schema_versions.count != 1
              # Scripts may be attached to more than one EP in the future but not right now
              err_tag = "script.error.metadata_schema_versions_single_key"
            elsif schema_major_version.nil?
              err_tag = "script.error.metadata_schema_versions_missing_major"
            elsif schema_minor_version.nil?
              err_tag = "script.error.metadata_schema_versions_missing_minor"
            end

            Metadata.new(schema_major_version, schema_minor_version)
          rescue JSON::ParserError
            err_tag = "script.error.metadata_validation_cause"
          ensure
            raise Errors::MetadataValidationError, ctx.message(err_tag) if err_tag
          end
        end
      end
    end
  end
end
