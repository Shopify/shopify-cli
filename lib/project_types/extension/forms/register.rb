# frozen_string_literal: true

module Extension
  module Forms
    class Register < ShopifyCli::Form
      flag_arguments :api_key

      attr_reader :app

      def ask
        self.app = ask_app
      end

      private

      attr_writer :app

      def ask_app
        apps = load_apps

        if !api_key.nil?
          found_app = apps.find { |app| app.api_key == api_key }
          ctx.abort(ctx.message('register.invalid_api_key',api_key)) if found_app.nil?
          found_app
        else
          CLI::UI::Prompt.ask(ctx.message('register.ask_app')) do |handler|
            apps.each do |app|
              handler.option("#{app.title} by #{app.business_name}") { app }
            end
          end
        end
      end

      def load_apps
        ctx.puts(@ctx.message('register.loading_apps'))
        apps = Tasks::GetApps.call(context: ctx)

        apps.empty? ? abort_no_apps : apps
      end

      def abort_no_apps
        ctx.puts(@ctx.message('register.no_apps'))
        ctx.puts(@ctx.message('register.learn_about_apps'))
        raise ShopifyCli::AbortSilent
      end
    end
  end
end
