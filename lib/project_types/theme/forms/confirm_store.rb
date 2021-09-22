module Theme
  module Forms
    class ConfirmStore < ShopifyCLI::Form
      flag_arguments :title, :force

      def ask
        @confirmed = force || CLI::UI::Prompt.confirm(title, default: false)
      end

      def confirmed?
        @confirmed
      end
    end
  end
end
