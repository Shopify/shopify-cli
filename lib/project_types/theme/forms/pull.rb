module Theme
  module Forms
    class Pull < ShopifyCli::Form
      flag_arguments :themeid, :password, :store

      def ask
        self.store ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_store'), allow_empty: false)
        ctx.puts(ctx.message('theme.forms.pull.private_app', store))
        self.password ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.ask_password'), allow_empty: false)
        ctx.system(Themekit::THEMEKIT, "get --list ---store=#{store} --password=#{password}")
        self.themeid ||= CLI::UI::Prompt.ask(ctx.message('theme.forms.pull.ask_theme_id'), allow_empty: false) # TODO: change to multiple choice

        errors = []
        errors << "store" if store.strip.empty?
        errors << "password" if password.strip.empty?
        errors << "theme ID" if themeid.strip.empty?
        ctx.abort(ctx.message('theme.forms.errors', errors.join(", ").capitalize)) unless errors.empty?
      end
    end
  end
end
