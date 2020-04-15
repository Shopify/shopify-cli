# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class InvalidExtensionPointError < StandardError
        attr_reader :type

        def initialize(type:)
          @type = type
          super("Extension point #{type} can't be found")
        end
      end
    end
  end
end
