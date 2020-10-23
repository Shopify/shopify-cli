module Theme
  module Commands
    class Generate
      class Env < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--store=STORE') { |url| flags[:store] = url }
          parser.on('--password=PASSWORD') { |p| flags[:password] = p }
          parser.on('--themeid=THEME_ID') { |id| flags[:themeid] = id }
          parser.on('--env=ENV') { |env| flags[:env] = env }
        end

        def call(*)
          default_store, default_password = fetch_credentials
          store = ask_store(default_store) || default_store
          password = ask_password(default_password) || default_password
          themeid = ask_theme(store: store, password: password)
          env = options.flags[:env]

          Themekit.generate_env(@ctx, store: store, password: password, themeid: themeid, env: env)
        end

        def self.help
          ShopifyCli::Context.message('theme.generate.env.help', ShopifyCli::TOOL_NAME)
        end

        private

        def fetch_credentials
          unless File.exist?('config.yml')
            return nil
          end

          config = YAML.load_file('config.yml')
          store = config['development']['store']
          password = config['development']['password']

          [store, password]
        end

        def ask_store(default)
          store = options.flags[:store] ||
            if default
              CLI::UI::Prompt.ask(@ctx.message('theme.generate.env.ask_store_default', default))
            else
              CLI::UI::Prompt.ask(@ctx.message('theme.generate.env.ask_store'), allow_empty: false)
            end
          return nil if store.empty?
          store
        end

        def ask_password(default)
          password = options.flags[:password] ||
            if default
              CLI::UI::Prompt.ask(@ctx.message('theme.generate.env.ask_password_default', default))
            else
              CLI::UI::Prompt.ask(@ctx.message('theme.generate.env.ask_password'), allow_empty: false)
            end
          return nil if password.empty?
          password
        end

        def ask_theme(store:, password:)
          theme = options.flags[:themeid]
          return theme if theme

          themes = Themekit.query_themes(@ctx, store: store, password: password)

          theme = CLI::UI::Prompt.ask(@ctx.message('theme.generate.env.ask_theme')) do |handler|
            themes.each do |name, id|
              handler.option(name) { id }
            end
          end
          theme
        end
      end
    end
  end
end
