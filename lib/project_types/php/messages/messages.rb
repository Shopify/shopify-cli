# frozen_string_literal: true

module PHP
  module Messages
    MESSAGES = {
      php: {
        help: <<~HELP,
          Suite of commands for developing PHP apps with Laravel. See {{command:%1$s php <command> --help}} for usage of each command.
            Usage: {{command:%1$s php [ %2$s ]}}
        HELP

        connect: {
          connected: "Project now connected to {{green:%s}}",
          help: <<~HELP,
            {{command:%s php connect}}: Connects an existing PHP app to Shopify CLI. Creates a config file.
              Usage: {{command:%s php connect}}
          HELP
          production_warning: <<~MESSAGE,
            {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
            MESSAGE
        },

        create: {
          help: <<~HELP,
            {{command:%s create php}}: Creates an embedded PHP app.
              Usage: {{command:%s create php}}
              Options:
                {{command:--name=NAME}} App name. Any string.
                {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                {{command:--shop-domain=MYSHOPIFYDOMAIN}} Development store URL. Must be an existing development store.
                {{command:--type=APPTYPE}} Whether this app is public or custom.
                {{command:--verbose}} Output verbose information when installing dependencies.
            HELP

          error: {
            php_required: <<~VERSION,
              PHP is required to create an app project. For installation instructions, visit:
                {{underline:https://www.php.net/manual/en/install.php}}
              VERSION
            php_version_failure: <<~VERSION,
              Failed to get the current PHP version. Please make sure it is installed as per the instructions at:
                {{underline:https://www.php.net/manual/en/install.php.}}
              VERSION
            php_version_too_low: "Your PHP version is too low. Please use version %s or higher.",
            composer_required: <<~COMPOSER,
              Composer is required to create an app project. Download at:
                {{underline:https://getcomposer.org/download/}}
              COMPOSER
            npm_required: "npm is required to create an app project. Download at https://www.npmjs.com/get-npm.",
            npm_version_failure: "Failed to get the current npm version. Please make sure it is installed as per " \
              "the instructions at https://www.npmjs.com/get-npm.",
            app_setup: "Failed to set up the app",
          },

          php_version: "PHP %s",
          npm_version: "npm %s",
          app_setting_up: "Setting up app…",
          app_set_up: "App is now set up",
        },

        open: {
          help: <<~HELP,
            Open your local development app in the default browser.
              Usage: {{command:%s open}}
            HELP
        },

        deploy: {
          help: <<~HELP,
            Deploy the current PHP project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
              Usage: {{command:%s deploy [ heroku ]}}
            HELP

          extended_help: <<~HELP,
            {{bold:Subcommands:}}
              {{cyan:heroku}}: Deploys the current PHP project to Heroku.
                Usage: {{command:%s deploy heroku}}
            HELP

          heroku: {
            help: <<~HELP,
              Deploy the current PHP project to Heroku
                Usage: {{command:%s deploy heroku}}
              HELP

            error: {
              generate_app_key: "Failed to generate Laravel APP_KEY",
            },

            downloading: "Downloading Heroku CLI…",
            downloaded: "Downloaded Heroku CLI",
            installing: "Installing Heroku CLI…",
            installing_windows: "Running Heroku CLI install wizard…",
            installed: "Installed Heroku CLI",
            authenticating: "Authenticating with Heroku…",
            authenticated: "{{v}} Authenticated with Heroku",
            authenticated_with_account: "{{v}} Authenticated with Heroku as `%s`",
            deploying: "Deploying to Heroku…",
            deployed: "Deployed to Heroku",
            post_deploy: <<~DEPLOYED,
              {{v}} Deployed to Heroku, you can access your app at {{green:%s}}

                If you're deploying this app for the first time, make sure to set up your database and your app's environment at {{bold:App dashboard -> Settings -> Config Vars}}.

                When setting your config vars, don't forget to set up your database and the appropriate Laravel values for it, particularly {{bold:DB_CONNECTION and DB_DATABASE}}.
              DEPLOYED
            git: {
              checking: "Checking git repo…",
              initialized: "Git repo initialized",
              what_branch: "What branch would you like to deploy?",
              branch_selected: "{{v}} Git branch `%s` selected for deploy",
            },
            app: {
              no_apps_found: "No existing Heroku app found. What would you like to do?",
              name: "What is your Heroku app’s name?",
              select: "Specify an existing Heroku app",
              selecting: "Selecting Heroku app `%s`…",
              selected: "{{v}} Heroku app `%s` selected",
              create: "Create a new Heroku app",
              creating: "Creating new Heroku app…",
              created: "{{v}} New Heroku app created",
              setting_configs: "Setting Shopify app configs…",
              configs_set: "{{v}} Shopify app configs set",
            },
          },
        },

        serve: {
          help: <<~HELP,
            Start a local development PHP server for your project, as well as a public ngrok tunnel to your localhost.
              Usage: {{command:%s serve}}
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
              Usage: {{command:%s tunnel [ auth | start | stop ]}}
            HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}

              {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
                Usage: {{command:%1$s tunnel auth <token>}}

              {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
                Usage: {{command:%1$s tunnel start}}

              {{cyan:stop}}: Stops the ngrok tunnel.
                Usage: {{command:%1$s tunnel stop}}

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
            },
            app_name: "App name",
            app_type: {
              select: "What type of app are you building?",
              select_public: "Public: An app built for a wide merchant audience.",
              select_custom: "Custom: An app custom built for a single client.",
              selected: "App type {{green:%s}}",
            },
          },
        },
      },
    }.freeze
  end
end
