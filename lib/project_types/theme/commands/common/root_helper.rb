# frozen_string_literal: true

require "project_types/theme/models/specification_handlers/theme"

module Theme
  class Command
    module Common
      module RootHelper
        def root_value(options, name)
          argv = default_argv(options)
          command_index = argv.index(name.to_s)

          return "." if command_index.nil?

          next_index = command_index + 1
          option_by_key = options_map(options)

          while next_index < argv.size
            element = argv[next_index]
            key, value = key_value_tuple(element)
            option = option_by_key[key]

            return element if option.nil?

            # Skip the option argument
            next_index += 1 if !option.arg.nil? && !value

            # PATTERN arguments take precedence over the `root`
            if option.arg =~ /PATTERN/ && !value
              next_index += 1 while option_argument?(argv, next_index, option_by_key)
              next
            end

            next_index += 1
          end

          "."
        end

        def is_theme_directory?(root)
          theme_directory = Theme::Models::SpecificationHandlers::Theme.new(root)
          unless theme_directory.valid?
            return unless Forms::ConfirmStore.ask(
              @ctx,
              [],
              title: @ctx.message("theme.confirm_current_directory"),
              force: options.flags[:force],
            ).confirmed?
          end
        end

        private

        def default_argv(options)
          options.parser.default_argv.compact
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

        def option_argument?(argv, next_index, option_by_key)
          return false unless next_index < argv.size

          element = argv[next_index]
          key, _value = key_value_tuple(element)
          option_by_key[key].nil?
        end

        def key_value_tuple(element)
          element.split("=")
        end
      end
    end
  end
end
