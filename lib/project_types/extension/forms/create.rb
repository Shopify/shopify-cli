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
        @directory_name ||= name.strip.gsub(/( )/, "_").downcase
      end

      private

      attr_writer :app

      def ask_app
        if !api_key.nil?
          found_app = Tasks::GetApp.call(context: ctx, api_key: api_key)
          ctx.abort(ctx.message("register.invalid_api_key", api_key)) if found_app.nil?
          found_app
        else
          apps = load_apps
          CLI::UI::Prompt.ask(ctx.message("register.ask_app")) do |handler|
            apps.each do |app|
              handler.option("#{app.title} by #{app.business_name}") { app }
            end
          end
        end
      end

      def load_apps
        ctx.puts(@ctx.message("register.loading_apps"))
        apps = Tasks::GetApps.call(context: ctx)

        apps.empty? ? abort_no_apps : apps
      end

      def abort_no_apps
        ctx.puts(@ctx.message("register.no_apps"))
        ctx.puts(@ctx.message("register.learn_about_apps"))
        raise ShopifyCli::AbortSilent
      end

      def ask_name
        ask_with_reprompt(
          initial_value: name,
          break_condition: -> (current_name) { Models::Registration.valid_title?(current_name) },
          prompt_message: ctx.message("create.ask_name"),
          reprompt_message: ctx.message("create.invalid_name", Models::Registration::MAX_TITLE_LENGTH)
        )
      end

      def ask_type
        return Extension.specifications[type] if Extension.specifications.valid?(type)
        ctx.puts(ctx.message("create.invalid_type")) unless type.nil?

        CLI::UI::Prompt.ask(ctx.message("create.ask_type")) do |handler|
          Extension.specifications.each do |type|
            handler.option("#{type.name} #{type.tagline}") { type }
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
