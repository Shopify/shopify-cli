# frozen_string_literal: true

module Theme
  class Command
    module Common
      module RootHelper
        def root_value(options, name)
          argv = default_argv(options)
          command_index = argv.index(name)

          return "." if command_index.nil?

          next_index = command_index + 1
          option_by_key = options_map(options)

          while next_index < argv.size
            element = argv[next_index]
            option = option_by_key[element]

            return element if option.nil?

            # PATTERN arguments take precedence over the `root`
            return "." if option.arg =~ /PATTERN/

            # Skip the option argument
            next_index += 1 unless option.arg.nil?

            next_index += 1
          end

          "."
        end

        private

        def default_argv(options)
          options.parser.default_argv
        end

        def options_map(options)
          map = {}
          options_list(options).each do |option|
            map[option.short.first] = option
            map[option.long.first] = option
          end
          map
        end

        def options_list(options)
          options.parser.top.list
        end
      end
    end
  end
end
