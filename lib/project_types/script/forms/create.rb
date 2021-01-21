# frozen_string_literal: true

module Script
  module Forms
    class Create < ShopifyCli::Form
      flag_arguments :extension_point, :name, :language

      def ask
        self.name = valid_name
        self.language = ask_language
        self.extension_point ||= ask_extension_point
      end

      private

      def ask_extension_point
        CLI::UI::Prompt.ask(
          @ctx.message('script.forms.create.select_extension_point'),
          options: Script::Layers::Application::ExtensionPoints.non_deprecated_types
        )
      end

      def ask_name
        CLI::UI::Prompt.ask(@ctx.message('script.forms.create.script_name'))
      end

      def valid_name
        n = (name || ask_name).downcase.gsub(' ', '_')
        return n if n.match?(/^[0-9A-Za-z_-]*$/)
        raise Errors::InvalidScriptNameError
      end

      def ask_language
        all_languages = Layers::Application::SupportedLanguages.all

        if language
          requested = all_languages.find { |l| l == language }
          return requested if requested
          raise Errors::InvalidLanguageError, language
        end

        return all_languages.first if all_languages.count == 1

        CLI::UI::Prompt.ask(
          ctx.message('script.forms.create.select_language'),
          options: all_languages
        )
      end
    end
  end
end
