# frozen_string_literal: true

module Node
  module Messages
    MESSAGES = {
      node: {
        help: <<~HELP,
          Suite of commands for developing Node.js apps. See {{command:%1$s node <command> --help}} for usage of each command.
            Usage: {{command:%1$s node [ %2$s ]}}
        HELP

        error: {
          generic: "Error",
        },

        connect: {
          connected: "Project now connected to {{green:%s}}",
          help: <<~HELP,
            {{command:%s node connect}}: Connects an existing Node.js app to Shopify CLI. Creates a config file.
              Usage: {{command:%s node connect}}
          HELP
          production_warning: <<~MESSAGE,
            {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
          MESSAGE
        },

        create: {
          help: <<~HELP,
            {{command:%s node create}}: Creates an embedded nodejs app.
              Usage: {{command:%s node create}}
              Options:
                {{command:--name=NAME}} App name. Any string.
                {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                {{command:--store=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
          HELP
          error: {
            node_required: "node is required to create an app project. Download at https://nodejs.org/en/download.",
            node_version_failure: "Failed to get the current node version. Please make sure it is installed as " \
              "per the instructions at https://nodejs.org/en.",
            npm_required: "npm is required to create an app project. Download at https://www.npmjs.com/get-npm.",
            npm_version_failure: "Failed to get the current npm version. Please make sure it is installed as per " \
              "the instructions at https://www.npmjs.com/get-npm.",
          },
          node_version: "node %s",
          npm_version: "npm %s",
        },

        deploy: {
          help: <<~HELP,
            Deploy the current Node project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
              Usage: {{command:%s node deploy [ heroku ]}}
          HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}
              {{cyan:heroku}}: Deploys the current Node project to Heroku.
                Usage: {{command:%s node deploy heroku}}
          HELP
          heroku: {
            help: <<~HELP,
              Deploy the current Node project to Heroku
                Usage: {{command:%s node deploy heroku}}
            HELP
            downloading: "Downloading Heroku CLI…",
            downloaded: "Downloaded Heroku CLI",
            installing: "Installing Heroku CLI…",
            installing_windows: "Running Heroku CLI install wizard…",
            installed: "Installed Heroku CLI",
            authenticating: "Authenticating with Heroku…",
            authenticated: "{{v}} Authenticated with Heroku",
            authenticated_with_account: "{{v}} Authenticated with Heroku as {{green:%s}}",
            deploying: "Deploying to Heroku…",
            deployed: "{{v}} Deployed to Heroku",
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
            {{red:The {{command:generate}} command is no longer supported.}}
              You can complete any tasks previously supported by {{command:generate}} with these guides:
              {{green:page}}
                Create a page with Polaris design components: {{green:https://shopify.dev/tutorials/build-a-shopify-app-with-node-and-react/build-your-user-interface-with-polaris}}

              {{green:webhook}}
                Register and process webhooks: {{green:https://github.com/Shopify/shopify-node-api/blob/main/docs/usage/webhooks.md}}

              {{green:billing}}
                Create and manage app billing models: {{green:https://shopify.dev/tutorials/bill-for-your-app-using-graphql-admin-api}}
          HELP
        },

        open: {
          help: <<~HELP,
            Open your local development app in the default browser.
              Usage: {{command:%s node open}}
          HELP
        },

        serve: {
          help: <<~HELP,
            Start a local development node server for your project, as well as a public ngrok tunnel to your localhost.
              Usage: {{command:%s node serve}}
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
              Usage: {{command:%s node tunnel [ auth | start | stop ]}}
          HELP
          extended_help: <<~HELP,
            {{bold:Subcommands:}}

              {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
                Usage: {{command:%1$s node tunnel auth <token>}}

              {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
                Usage: {{command:%1$s node tunnel start}}

              {{cyan:stop}}: Stops the ngrok tunnel.
                Usage: {{command:%1$s node tunnel stop}}

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
