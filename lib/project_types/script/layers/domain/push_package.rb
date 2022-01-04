# typed: true
# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id,
          :uuid,
          :extension_point_type,
          :script_config,
          :script_content,
          :compiled_type,
          :metadata,
          :library

        def initialize(
          id:,
          uuid:,
          extension_point_type:,
          script_content:,
          compiled_type: nil,
          metadata:,
          script_config:,
          library:
        )
          @id = id
          @uuid = uuid
          @extension_point_type = extension_point_type
          @script_content = script_content
          @compiled_type = compiled_type
          @metadata = metadata
          @script_config = script_config
          @library = library
        end
      end
    end
  end
end
