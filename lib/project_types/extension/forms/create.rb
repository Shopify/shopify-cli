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
        @directory_name ||= self.name.strip.gsub(/( )/, '_').downcase
      end

      private

      def ask_name
        ask_with_reprompt(
          initial_value: self.name,
          break_condition: -> (current_name) { Models::Registration.valid_title?(current_name) },
          prompt_message: Content::Create::ASK_NAME,
          reprompt_message: Content::Create::INVALID_NAME % Models::Registration::MAX_TITLE_LENGTH
        )
      end

      def ask_type
        return Models::Type.load_type(type) if Models::Type.valid?(type)
        ctx.puts(Content::Create::INVALID_TYPE) unless type.nil?

        CLI::UI::Prompt.ask(Content::Create::ASK_TYPE) do |handler|
          Models::Type.repository.values.each do |type|
            handler.option("#{type.name} #{type.tagline}") { type }
          end
        end
      end

      def ask_with_reprompt(initial_value:, break_condition:, prompt_message:, reprompt_message:)
        value = initial_value
        reprompt = false

        while !break_condition.call(value) do
          ctx.puts(reprompt_message) if reprompt
          value = CLI::UI::Prompt.ask(prompt_message)&.strip
          reprompt = true
        end
        value
      end
    end
  end
end
