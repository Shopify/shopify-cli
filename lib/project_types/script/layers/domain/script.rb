# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class Script
        attr_reader :id, :name, :extension_point_type, :language

        def initialize(id, name, extension_point_type, language)
          @id = id
          @name = name
          @extension_point_type = extension_point_type
          @language = language
        end
      end
    end
  end
end
