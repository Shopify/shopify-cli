module Theme
  module Forms
    class Connect < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :themeid, :password, :store, :env

      def ask
        self.store ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_store'), allow_empty: false)
        ctx.puts(ctx.message('theme.forms.connect.private_app', store))
        self.password ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_password'), allow_empty: false)

        errors = []
        errors << "store" if store.strip.empty?
        errors << "password" if password.strip.empty?
        ctx.abort(ctx.message('theme.forms.errors', errors.join(", ").capitalize)) unless errors.empty?

        self.themeid, self.name = ask_theme(store: store, password: password, themeid: themeid)
      end

      private

      def ask_theme(store:, password:, themeid:)
        themes = Themekit.query_themes(@ctx, store: store, password: password)

        themeid ||= CLI::UI::Prompt.ask("Select theme") do |handler|
          themes.each do |name, id|
            handler.option(name) { id }
          end
        end
        [themeid, themes.key(themeid.to_i)]
      end
    end
  end
end
