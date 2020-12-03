# frozen_string_literal: true

module Extension
  module Forms
    class Create < ShopifyCli::Form
      flag_arguments :name, :type

      def ask
        self.type = ask_type
        self.name = ask_name
      end

      def directory_name
        @directory_name ||= name.strip.gsub(/( )/, '_').downcase
      end

      private

      def ask_name
        ask_with_reprompt(
          initial_value: name,
          break_condition: -> (current_name) { Models::Registration.valid_title?(current_name) },
          prompt_message: ctx.message('create.ask_name'),
          reprompt_message: ctx.message('create.invalid_name', Models::Registration::MAX_TITLE_LENGTH)
        )
      end

      def ask_type
        type_symbol = @type.to_s.downcase.to_sym unless @type.nil?

        types_declarations = Tasks::GetTypeDeclarations.call(context: ctx)

        if !@type.nil? && types_declarations.any? { |declaration| declaration.load_type.cli_identifier == type_symbol }
          return Models::Type.load_type(type_symbol)
        end

        ctx.puts(ctx.message('create.invalid_type')) unless @type.nil?

        CLI::UI::Prompt.ask(ctx.message('create.ask_type')) do |handler|
          types_declarations.each do |type_declaration|
            handler.option("#{type_declaration.load_type.name} #{type_declaration.load_type.tagline}") do
              Models::Type.load_type(type_declaration.type)
            end
          end
        end
      end

      def ask_with_reprompt(initial_value:, break_condition:, prompt_message:, reprompt_message:)
        value = initial_value
        reprompt = false

        until break_condition.call(value)
          ctx.puts(reprompt_message) if reprompt
          value = CLI::UI::Prompt.ask(prompt_message)&.strip
          reprompt = true
        end
        value
      end
    end
  end
end
