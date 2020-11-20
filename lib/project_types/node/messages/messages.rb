# frozen_string_literal: true

module Node
  module Messages
    MESSAGES = {
      node: {
        error: {
          generic: "Error",
        },

        create: {
          help: <<~HELP,
          {{command:%s create node}}: Creates an embedded nodejs app.
            Usage: {{command:%s create node}}
            Options:
              {{command:--name=NAME}} App name. Any string.
              {{command:--app_url=APPURL}} App URL. Must be a valid URL.
              {{command:--organization_id=ID}} Partner organization ID. Must be an existing organization.
              {{command:--shop_domain=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
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
            Usage: {{command:%s deploy [ heroku ]}}
          HELP
          extended_help: <<~HELP,
          {{bold:Subcommands:}}
            {{cyan:heroku}}: Deploys the current Node project to Heroku.
              Usage: {{command:%s deploy heroku}}
          HELP
          heroku: {
            help: <<~HELP,
            Deploy the current Node project to Heroku
              Usage: {{command:%s deploy heroku}}
            HELP
            downloading: "Downloading Heroku CLI…",
            downloaded: "Downloaded Heroku CLI",
            installing: "Installing Heroku CLI…",
            installing_windows: "Running Heroku CLI install wizard…",
            installed: "Installed Heroku CLI",
            authenticating: "Authenticating with Heroku…",
            authenticated: "{{v}} Authenticated with Heroku",
            authenticated_with_account: "{{v}} Authenticated with Heroku as `%s`",
            deploying: "Deploying to Heroku…",
            deployed: "{{v}} Deployed to Heroku",
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
            },
          },
        },

        generate: {
          help: <<~HELP,
          Generate code in your Node project. Supports generating new billing API calls, new pages, or new webhooks.
            Usage: {{command:%s generate [ billing | page | webhook ]}}
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

          billing: {
            help: <<~HELP,
            Enable charging for your app. This command generates the necessary code to call Shopify’s billing API.
              Usage: {{command:%s generate billing [ one-time-billing | recurring-billing ]}}
            HELP
            type_select: "How would you like to charge for your app?",
            generating: "Generating %s code ...",
            generated: "{{green:%s}} generated in server/server.js",
          },

          page: {
            help: <<~HELP,
            Generate a new page in your app with the specified name. New files are generated inside the project’s “/pages” directory.
              Usage: {{command:%s generate page <pagename>}}
            HELP
            error: {
              invalid_page_type: "Invalid page type.",
            },
            type_select: "Which template would you like to use?",
            generating: "Generating %s page...",
            generated: "{{green: %s}} generated in pages/%s",
          },

          webhook: {
            help: <<~HELP,
            Generate and register a new webhook that listens for the specified Shopify store event.
              Usage: {{command:%s generate webhook <type>}}
            HELP
            type_select: "What type of webhook would you like to create?",
            generating: "Generating webhook: %s",
            generated: "{{green:%s}} generated in server/server.js",
          },
        },

        open: {
          help: <<~HELP,
          Open your local development app in the default browser.
            Usage: {{command:%s open}}
          HELP
        },

        populate: {
          help: <<~HELP,
          Populate your Shopify development store with example customers, orders, or products.
            Usage: {{command:%s populate [ customers | draftorders | products ]}}
          HELP
          extended_help: <<~HELP,
          {{bold:Subcommands:}}

            {{cyan:customers [options]}}: Add dummy customers to the specified development store.
              Usage: {{command:%1$s populate customers}}

            {{cyan:draftorders [options]}}: Add dummy orders to the specified development store.
              Usage: {{command:%1$s populate draftorders}}

            {{cyan:products [options]}}: Add dummy products to the specified development store.
              Usage: {{command:%1$s populate products}}

          {{bold:Options:}}

            {{cyan:--count [integer]}}: The number of dummy items to populate. Defaults to 5.
            {{cyan:--silent}}: Silence the populate output.
            {{cyan:--help}}: Display more options specific to each subcommand.

          {{bold:Examples:}}

            {{command:%1$s populate products}}
              Populate your development store with 5 additional products.

            {{command:%1$s populate customers --count 30}}
              Populate your development store with 30 additional customers.

            {{command:%1$s populate draftorders}}
              Populate your development store with 5 additional orders.

            {{command:%1$s populate products --help}}
              Display the list of options available to customize the {{command:%1$s populate products}} command.
          HELP

          customer: {
            added: "%s added to {{green:%s}} at {{underline:%scustomers/%d}}",
          },

          draft_order: {
            added: "DraftOrder added to {{green:%s}} at {{underline:%sdraft_orders/%d}}",
          },

          product: {
            added: "%s added to {{green:%s}} at {{underline:%sproducts/%d}}",
          },
        },

        serve: {
          help: <<~HELP,
          Start a local development node server for your project, as well as a public ngrok tunnel to your localhost.
            Usage: {{command:%s serve}}
          HELP
          extended_help: <<~HELP,
          {{bold:Options:}}
            {{cyan:--host=HOST}}: Bypass running tunnel and use custom host. HOST must be HTTPS url.
          HELP

          error: {
            host_must_be_https: "HOST must be a HTTPS url.",
          },

          open_info: <<~MESSAGE,
            {{*}} To install and start using your app, open this URL in your browser:
            {{green:%s}}
          MESSAGE
          running_server: "Running server...",
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
