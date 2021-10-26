# frozen_string_literal: true

module Rails
  module Messages
    MESSAGES = {
      rails: {
        help: <<~HELP,
          Suite of commands for developing Ruby on Rails apps. See {{command:%1$s rails <command> --help}} for usage of each command.
            Usage: {{command:%1$s rails [ %2$s ]}}
        HELP

        error: {
          generic: "Error",
        },

        gem: {
          checking_installation_path: "Checking path %s for gem %s",
          installed: "Installed %s gem",
          installed_debug: "%s installed: %s",
          installing: "Installing %s gem…",
          setting_gem_home: "GEM_HOME being set to %s",
          setting_gem_path: "GEM_PATH being set to %s",
        },

        connect: {
          connected: "Project now connected to {{green:%s}}",
          help: <<~HELP,
            {{command:%s rails connect}}: Connects an existing Ruby on Rails app to Shopify CLI. Creates a config file.
              Usage: {{command:%s rails connect}}
          HELP
          production_warning: <<~MESSAGE,
            {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
          MESSAGE
        },

        create: {
          help: <<~HELP,
            {{command:%s rails create}}: Creates a ruby on rails app.
              Usage: {{command:%s rails create}}
              Options:
                {{command:--name=NAME}} App name. Any string.
                {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                {{command:--store=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
                {{command:--db=DB}} Database type. Must be one of: mysql, postgresql, sqlite3, oracle, frontbase, ibm_db, sqlserver, jdbcmysql, jdbcsqlite3, jdbcpostgresql, jdbc.
                {{command:--rails-opts=RAILSOPTS}} Additional options. Must be string containing one or more valid Rails options, separated by spaces.
          HELP

          error: {
            invalid_ruby_version: "This project requires a Ruby version ~> 2.5 or Ruby 3.0.",
            dir_exists: "Project directory %s already exists. Please use a different name.",
            install_failure: "Error installing %s gem",
            node_required: "node is required to create a rails project. Download at https://nodejs.org/en/download.",
            node_version_failure: "Failed to get the current node version. Please make sure it is installed as " \
              "per the instructions at https://nodejs.org/en.",
            yarn_required: "yarn is required to create a rails project. Download at " \
              "https://classic.yarnpkg.com/en/docs/install.",
            yarn_version_failure: "Failed to get the current yarn version. Please make sure it is installed as per " \
              "the instructions at https://classic.yarnpkg.com/en/docs/install.",
          },

          info: {
            open_new_shell: "{{*}} {{yellow:After installing %s, please open a new Command Prompt or PowerShell " \
              "window to continue.}}",
          },
          installing_bundler: "Installing bundler…",
          generating_app: "Generating new rails app project in %s…",
          adding_shopify_gem: "{{v}} Adding shopify_app gem…",
          node_version: "node %s",
          yarn_version: "yarn %s",
          running_bundle_install: "Running bundle install…",
          running_generator: "Running shopify_app generator…",
          running_migrations: "Running migrations…",
          running_webpacker_install: "Running webpacker:install…",
        },

        deploy: {
          help: <<~HELP,
            Deploy the current Rails project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
              Usage: {{command:%s rails deploy [ heroku ]}}
          HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}
              {{cyan:heroku}}: Deploys the current Rails project to Heroku.
                Usage: {{command:%s rails deploy heroku}}
          HELP

          heroku: {
            help: <<~HELP,
              Deploy the current Rails project to Heroku
              Usage: {{command:%s rails deploy heroku}}
            HELP
            downloading: "Downloading Heroku CLI…",
            downloaded: "Downloaded Heroku CLI",
            installing: "Installing Heroku CLI…",
            installed: "Installed Heroku CLI",
            authenticated_with_account: "{{v}} Authenticated with Heroku as {{green:%s}}",
            authenticating: "Authenticating with Heroku…",
            authenticated: "{{v}} Authenticated with Heroku",
            deploying: "Deploying to Heroku…",
            deployed: "{{v}} Deployed to Heroku",
            db_check: {
              validating: "Validating application…",
              checking: "Checking database type…",
              validated: "Database type \"%s\" validated for platform \"Heroku\"",
              problem: "A problem was encountered while checking your database type.",
              sqlite: <<~SQLITE,
                Heroku does not support deployment using the SQLite database system.
                Change the database type using {{command:rails db:system:change --to=[new_db_type]}}. For more info:
                {{underline:https://gorails.com/episodes/rails-6-db-system-change-command}}
              SQLITE
            },
            git: {
              checking: "Checking git repo…",
              initialized: "Git repo initialized",
              what_branch: "What branch would you like to deploy?",
              branch_selected: "{{v}} Git branch {{green:%s}} selected for deploy",
            },
            app: {
              no_apps_found: "No existing Heroku app found. What would you like to do?",
              name: "What is your Heroku app’s name?",
              select: "Specify an existing Heroku app",
              selecting: "Selecting Heroku app %s…",
              selected: "{{v}} Heroku app {{green:%s}} selected",
              create: "Create a new Heroku app",
              creating: "Creating new Heroku app…",
              created: "{{v}} New Heroku app created",
            },
          },
        },

        generate: {
          help: <<~HELP,
            Generate code in your Rails project. Currently supports generating new webhooks.
              Usage: {{command:%s rails generate [ webhook ]}}
          HELP
          extended_help: <<~EXAMPLES,
            {{bold:Examples:}}
              {{cyan:%s generate webhook PRODUCTS_CREATE}}
                Generate and register a new webhook that will be called every time a new product is created on your store.
          EXAMPLES

          error: {
            name_exists: "%s already exists!",
            generic: "Error generating %s",
          },

          webhook: {
            help: <<~HELP,
              Generate and register a new webhook that listens for the specified Shopify store event.
                Usage: {{command:%s rails generate webhook <type>}}
            HELP

            select: "What type of webhook would you like to create?",
            selected: "Generating webhook: %s",
          },
        },

        open: {
          help: <<~HELP,
            Open your local development app in the default browser.
              Usage: {{command:%s rails open}}
          HELP
        },

        serve: {
          help: <<~HELP,
            Start a local development rails server for your project, as well as a public ngrok tunnel to your localhost.
              Usage: {{command:%s rails serve}}
          HELP
          extended_help: <<~HELP,
            {{bold:Options:}}
              {{cyan:--host=HOST}}: Bypass running tunnel and use custom host. HOST must be HTTPS url.
              {{cyan:--port=PORT}}: Use custom port.
          HELP

          open_info: <<~MESSAGE,
            {{*}} To install and start using your app, open this URL in your browser:
            {{green:%s}}
          MESSAGE
          running_server: "Running server…",
        },

        tunnel: {
          help: <<~HELP,
            Start or stop an http tunnel to your local development app using ngrok.
              Usage: {{command:%s rails tunnel [ auth | start | stop ]}}
          HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}

              {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
                Usage: {{command:%1$s rails tunnel auth <token>}}

              {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
                Usage: {{command:%1$s rails tunnel start}}

              {{cyan:stop}}: Stops the ngrok tunnel.
                Usage: {{command:%1$s rails tunnel stop}}

          HELP

          error: {
            token_argument_missing: "{{x}} {{red:auth requires a token argument}}\n\n",
          },
        },

        forms: {
          create: {
            error: {
              invalid_app_name: "App name cannot contain 'Shopify'",
              invalid_app_type: "Invalid app type %s",
              invalid_db_type: "Invalid database type %s",
            },
            app_name: "App name",
            app_type: {
              select: "What type of app are you building?",
              select_public: "Public: An app built for a wide merchant audience.",
              select_custom: "Custom: An app custom built for a single client.",
              selected: "App type {{green:%s}}",
            },
            db: {
              want_select: <<~WANT_SELECT,
                Would you like to select what database type to use now? (SQLite is the default)
                If you want to change this in the future, run {{command:rails db:system:change --to=[new_db_type]}}. For more info:
                {{underline:https://gorails.com/episodes/rails-6-db-system-change-command}}
              WANT_SELECT
              select: "What database type would you like to use? Please ensure the database is installed.",
              select_sqlite3: "SQLite (default)",
              select_mysql: "MySQL",
              select_postgresql: "PostgreSQL",
              select_oracle: "Oracle",
              select_frontbase: "FrontBase",
              select_ibm_db: "IBM_DB",
              select_sqlserver: "SQL Server",
              select_jdbcmysql: "JDBC MySQL",
              select_jdbcsqlite3: "JDBC SQlite",
              select_jdbcpostgresql: "JDBC PostgreSQL",
              select_jdbc: "JDBC",
              selected: "Database Type {{green:%s}}",
            },
          },
        },
      },
    }.freeze
  end
end
