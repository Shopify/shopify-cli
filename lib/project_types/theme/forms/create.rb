module Theme
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :title, :password, :store, :env

      def ask
        self.store ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_store'), allow_empty: false)
        ctx.puts(ctx.message('theme.forms.create.private_app', store))
        self.password ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_password'), allow_empty: false)
        self.title ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.create.ask_title'), allow_empty: false)
        self.name = self.title.downcase.split(" ").join("_")

        errors = []
        errors << "store" if store.strip.empty?
        errors << "password" if password.strip.empty?
        errors << "title" if title.strip.empty?
        ctx.abort(ctx.message('theme.forms.errors', errors.join(", ").capitalize)) unless errors.empty?
      end
    end
  end
end
