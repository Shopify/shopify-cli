# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class PushPackage
        attr_reader :id,
          :uuid,
          :extension_point_type,
          :title,
          :description,
          :script_config,
          :script_content,
          :metadata,
          :library

        def initialize(
          id:,
          uuid:,
          extension_point_type:,
          title:,
          description:,
          script_content:,
          metadata:,
          script_config:,
          library:
        )
          @id = id
          @uuid = uuid
          @extension_point_type = extension_point_type
          @title = title
          @description = description
          @script_content = script_content
          @metadata = metadata
          @script_config = script_config
          @library = library
        end
      end
    end
  end
end
