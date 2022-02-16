# frozen_string_literal: true

module Theme
  module Conversions
    class BaseGlob
      class << self
        def register(parser)
          parser.accept(self) { |_val| convert(parser) }
        end

        def convert(parser)
          argv = parser.default_argv
          option_index = argv.index { |v| options.include?(v) }

          return [] if option_index.nil?

          option_values(argv, option_index)
        end

        def options
          raise "`#{self.class.name}#options` must be defined"
        end

        private

        def option_values(argv, option_index)
          start_index = option_index + 1
          values = []

          argv[start_index..-1].each do |value|
            return values if parameter?(value)
            values << value
          end

          values
        end

        def parameter?(value)
          value.start_with?("-")
        end
      end
    end
  end
end
