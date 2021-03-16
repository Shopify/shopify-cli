# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ConfigUi
        attr_reader :filename, :content

        def initialize(filename:, content:)
          @filename = filename
          @content = content
        end
      end
    end
  end
end
