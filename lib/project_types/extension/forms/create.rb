# frozen_string_literal: true

module Extension
  module Forms
    class Create < ShopifyCli::Form
      flag_arguments :title, :type, :api_key

      ASK_TITLE = 'What is your extension\'s name?'
      ASK_TYPE = 'What type of extension would you like to create?'
      INVALID_TYPE = 'Invalid extension type.'
      ASK_APP = 'Which app would you like to associate with the extension?'
      NO_APPS = 'There are no registered apps. Create an app and try again'
      INVALID_API_KEY = 'The api key does not match any of the existing apps'

      attr_reader :app

      def ask
        self.title = ask_title
        self.type = ask_type
        self.app = ask_app
      end

      def name
        @name ||= self.title.strip.gsub(/( )/, '_').downcase
      end

      protected

      attr_writer :app

      private

      def ask_title
        return title unless title.nil? || title.strip.empty?
        CLI::UI::Prompt.ask(ASK_TITLE)
      end

      def ask_type
        return type if Models::Type.valid?(type)
        ctx.puts(INVALID_TYPE) unless type.nil?

        CLI::UI::Prompt.ask(ASK_TYPE) do |handler|
          Models::Type.all.each do |type|
            handler.option(type.name) { type.identifier }
          end
        end
      end

      def ask_app
        apps = Tasks::GetApps.call(context: ctx)
        ctx.abort(NO_APPS) if apps.empty?

        if !api_key.nil?
          found_app = apps.find { |app| app.api_key == api_key }
          ctx.abort(INVALID_API_KEY) if found_app.nil?
          found_app
        else
          CLI::UI::Prompt.ask(ASK_APP) do |handler|
            apps.each do |app|
              handler.option("#{app.title} by #{app.business_name}") { app }
            end
          end
        end
      end
    end
  end
end
