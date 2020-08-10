module Theme
  module Forms
    class Serve < ShopifyCli::Form
      flag_arguments :env

      def ask
        self.env ||= ask_env
      end

      private

      def ask_env
        CLI::UI::Prompt.ask("Preview environment: ") do |handler|
          handler.option('Production') { 'production' }
          handler.option('Development') { 'development' }
          handler.option('Test') { 'test' }
        end
      end
    end
  end
end
