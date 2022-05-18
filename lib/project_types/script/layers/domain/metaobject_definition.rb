# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class MetaobjectDefinition
        attr_reader :content, :filename

        def initialize(content:, filename:)
          @filename = filename
          @content = content
        end
      end
    end
  end
end
