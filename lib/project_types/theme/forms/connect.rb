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

        themes = query_themes(store, password)
        self.themeid ||= ask_theme(themes)
        self.name = themes.key(themeid.to_i)
      end

      private

      def ask_theme(themes)
        CLI::UI::Prompt.ask("Select theme") do |handler|
          themes.each do |name, id|
            handler.option(name) { id }
          end
        end
      end

      def query_themes(store, password)
        begin
          resp = ::ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: store,
            token: password,
            path: "themes.json",
          )
        rescue ShopifyCli::API::APIRequestUnauthorizedError
          ctx.abort('bad password')
        rescue StandardError
          ctx.abort('could not connect to given shop')
        end

        resp[1]['themes'].map { |theme| [theme['name'], theme['id']] }.to_h
      end
    end
  end
end
