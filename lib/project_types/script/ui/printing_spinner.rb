# frozen_string_literal: true
require "shopify_cli"

module Script
  module UI
    module PrintingSpinner
      ##
      # Creates a single spinner that runs the provided block.
      # The block can take in a ctx argument that formats printed output to support
      # printing from within the spin block.
      #
      # ==== Attributes
      #
      # * +ctx+   - The current context.
      # * +title+ - Title of the spinner to use
      #
      # ==== Options
      #
      # * +:auto_debrief+ - Automatically debrief exceptions? Default to true
      #
      # ==== Block
      #
      # * +ctx+     - Instance of the PrintingSpinnerContext built from the ctx attribute.
      #             - +ctx.puts(...)+ formats output to enable support for printing within spinners
      # * +spinner+ - Instance of the spinner. Can call +update_title+ to update the user of changes
      #
      def self.spin(ctx, title, auto_debrief: false)
        StrictSpinner.spin(title, auto_debrief: auto_debrief) do |spinner, *args|
          Thread.current[:cliui_output_hook] = nil
          yield(PrintingSpinnerContext.from(ctx, spinner), spinner, *args)
        end
      end

      ##
      # Printing within spinners requires the manipulation of ANSI escape
      # sequences in order to make sure the CLI::UI::Spinner does not overwrite
      # previously printed content.
      class PrintingSpinnerContext < ShopifyCLI::Context
        include SmartProperties
        property :spinner, required: true

        def self.from(ctx, spinner)
          new_ctx = new(spinner: spinner)
          ctx.instance_variables.each do |var|
            new_ctx.instance_variable_set(var, ctx.instance_variable_get(var))
          end
          new_ctx
        end

        def puts(*input)
          super(encoded_lines(*input) + "\n" + spinner_text)
        end

        private

        def encoded_lines(*lines)
          lines
            .join("\n")
            .split("\n")
            .map { |line| encode_ansi(line) unless line.nil? }
            .join(CLI::UI::ANSI.next_line + "\n")
        end

        def encode_ansi(line)
          CLI::UI::ANSI.previous_line + line + CLI::UI::ANSI.clear_to_end_of_line
        end

        def spinner_text
          spinner.render(0, true)
        end
      end
      private_constant(:PrintingSpinnerContext)
    end
  end
end
