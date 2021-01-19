module CLI
  module UI
    module Prompt
      # A class that handles the various options of an InteractivePrompt and their callbacks
      class OptionsHandler
        def initialize
          @options = {}
        end

        def options
          @options.keys
        end

        def option(option, &handler)
          @options[option] = handler
        end

        def call(selected_options)
          case selected_options
          when Array
            selected_options.map { |option| @options[option].call(selected_options) }
          else
            option = @options.fetch(selected_options) { raise ArgumentError, "Unknown Option" }
            option.call(selected_options)
          end
        end
      end
    end
  end
end
