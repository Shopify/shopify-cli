# frozen_string_literal: true

module Script
  module Forms
    class Create < ShopifyCli::Form
      positional_arguments :name
      flag_arguments :extension_point

      def ask
        self.extension_point ||= ask_extension_point
      end

      private

      def ask_extension_point
        CLI::UI::Prompt.ask(
          'Which extension point do you want to use?',
          options: Script::Layers::Application::ExtensionPoints.types
        )
      end
    end
  end
end
