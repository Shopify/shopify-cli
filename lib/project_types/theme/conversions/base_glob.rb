# frozen_string_literal: true

module Theme
  module Conversions
    class BaseGlob
      class << self
        def register(parser)
          parser.accept(self) { |_val| convert(parser) }
        end

        def convert(parser)
          elements = []
          argv = parser.default_argv
          index = argv.index { |v| options.include?(v) }

          return elements if index.nil?

          argv[(index + 1)..-1].each do |v|
            break if v.start_with?("-")
            elements << v
          end

          elements
        end

        def options
          raise "`#{self.class.name}#options` must be defined"
        end
      end
    end
  end
end
