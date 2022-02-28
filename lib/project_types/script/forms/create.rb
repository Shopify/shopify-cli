# frozen_string_literal: true

module Script
  module Forms
    class Create < ShopifyCLI::Form
      flag_arguments :extension_point, :title

      def ask
        self.title = valid_name
        self.extension_point ||= ask_extension_point
      end

      private

      def ask_extension_point
        CLI::UI::Prompt.ask(
          @ctx.message("script.forms.create.select_extension_point"),
          options: Layers::Application::ExtensionPoints.available_types
        )
      end

      def ask_title
        CLI::UI::Prompt.ask(@ctx.message("script.forms.create.script_title"))
      end

      def valid_name
        normalized_title = (title || ask_title).downcase.gsub(" ", "_")
        return normalized_title if normalized_title.match?(/^[0-9A-Za-z_-]*$/)
        raise Errors::InvalidScriptTitleError
      end
    end
  end
end
