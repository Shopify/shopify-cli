# frozen_string_literal: true

module Theme
  class Command
    module Common
      module RootHelper
        def root_value(args, options)
          first = args&.first

          if first.nil? || glob_params(options).include?(first)
            "."
          else
            first
          end
        end

        private

        def glob_params(options)
          return [] if options&.flags.nil?
          [
            options.flags[:includes],
            options.flags[:ignores],
          ].flatten.compact
        end
      end
    end
  end
end
