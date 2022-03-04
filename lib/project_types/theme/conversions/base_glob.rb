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
          values = []

          option_indexes(argv).each do |option_index|
            values += option_values(argv, parser, option_index)
          end

          values
        end

        def options
          raise "`#{self.class.name}#options` must be defined"
        end

        private

        def option_values(argv, parser, option_index)
          return [] if option_index.nil?

          start_index = option_index + 1
          option_by_key = options_map(parser)
          values = []

          argv[start_index..-1].each do |value|
            return values unless option_by_key[value].nil?
            values << value
          end

          values
        end

        def option_indexes(argv)
          argv
            .each_with_index
            .select { |item, _index| options.include?(item) }
            .map(&:last)
        end

        def options_map(parser)
          map = {}
          parser.top.list.each do |option|
            map[option.short.first] = option
            map[option.long.first] = option
          end
          map
        end

        def parameter?(value)
          value.start_with?("-")
        end
      end
    end
  end
end
