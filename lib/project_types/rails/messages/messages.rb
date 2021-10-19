# frozen_string_literal: true

module Rails
  module Messages
    MESSAGES = {
      rails: {
        help: <<~HELP,
          Suite of commands for developing Ruby on Rails apps. See {{command:%1$s app rails <command> --help}} for usage of each command.
            Usage: {{command:%1$s app rails [ %2$s ]}}
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
        deploy: {
          help: <<~HELP,
            Deploy the current Rails project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
              Usage: {{command:%s app rails deploy [ heroku ]}}
          HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}
              {{cyan:heroku}}: Deploys the current Rails project to Heroku.
                Usage: {{command:%s app rails deploy heroku}}
          HELP
        },

        generate: {
          help: <<~HELP,
            Generate code in your Rails project. Currently supports generating new webhooks.
              Usage: {{command:%s app rails generate [ webhook ]}}
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
                Usage: {{command:%s app rails generate webhook <type>}}
            HELP

            select: "What type of webhook would you like to create?",
            selected: "Generating webhook: %s",
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
