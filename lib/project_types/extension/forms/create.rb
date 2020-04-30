# frozen_string_literal: true

module Extension
  module Forms
    class Create < ShopifyCli::Form
      flag_arguments :name, :type, :api_key

      attr_reader :app

      def ask
        self.app = ask_app
        self.type = ask_type
        self.name = ask_name
      end

      def directory_name
        @directory_name ||= self.name.strip.gsub(/( )/, '_').downcase
      end

      protected

      attr_writer :app

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

      def ask_app
        apps = Tasks::GetApps.call(context: ctx)
        ctx.abort(Content::Create::NO_APPS) if apps.empty?

        if !api_key.nil?
          found_app = apps.find { |app| app.api_key == api_key }
          ctx.abort(Content::Create::INVALID_API_KEY % api_key) if found_app.nil?
          found_app
        else
          CLI::UI::Prompt.ask(Content::Create::ASK_APP) do |handler|
            apps.each do |app|
              handler.option("#{app.title} by #{app.business_name}") { app }
            end
          end
        end
      end

      private

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
