module Theme
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :title, :env

      def ask
        self.title ||= CLI::UI::Prompt.ask(ctx.message("theme.forms.create.ask_title"), allow_empty: false)
        self.name = self.title.downcase.split(" ").join("_")

        errors = []
        errors << "title" if title.strip.empty?
        ctx.abort(ctx.message("theme.forms.errors", errors.join(", ").capitalize)) unless errors.empty?
      end
    end
  end
end
