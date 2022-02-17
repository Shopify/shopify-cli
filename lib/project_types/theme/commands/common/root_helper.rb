# frozen_string_literal: true

module Theme
  class Command
    module Common
      module RootHelper
        def root_value(options, name)
          eligible_root = eligible_root(options, name)

          if eligible_root.nil? || parameter?(eligible_root)
            return "."
          end

          eligible_root
        end

        private

        def eligible_root(options, name)
          argv = default_argv(options)
          command_index = argv.index(name)

          argv[command_index + 1] unless command_index.nil?
        end

        def default_argv(options)
          options.parser.default_argv
        end

        def parameter?(value)
          value.start_with?("-")
        end
      end
    end
  end
end
