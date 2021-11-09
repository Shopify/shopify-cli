# frozen_string_literal: true

module ShopifyCLI
  module Messages
    MESSAGES = {
      apps: {
        create: {
          info: {
            created: "{{v}} {{green:%s}} was created in the organization's Partner Dashboard {{underline:%s}}",
            serve: "{{*}} Change directories to your new project folder {{green:%s}} and run "\
            "{{command:%s app serve}} to start a local server",
            install: "{{*}} Then, visit {{underline:%s/test}} to install {{green:%s}} on your Dev Store",
          },
        },
      },
      core: {
        app: {
          help: <<~HELP,
          Suite of commands for developing apps. See {{command:%1$s app <command> --help}} for usage of each command.
            Usage: {{command:%1$s app [ %2$s ]}}
          HELP
          error: {
            type_not_found: <<~MESSAGE,
            Couldn't detect the app type in directory %s. We currently support Rails, PHP, and NodeJS apps.
            MESSAGE
            missing_shopify_cli_yml: <<~MESSAGE,
            Couldn't find a #{Constants::Files::SHOPIFY_CLI_YML} file in the directory %s to determine the app type.
            MESSAGE
            invalid_project_type: <<~MESSAGE,
            The project type %s doesn't represent an app.
            MESSAGE
          },
          create: {
            type_required_error: "",
            invalid_type: "The type %s is not supported. The only supported types are"\
              " {{command:[ rails | node | php ]}}",
            help: <<~HELP,
            {{command:%s app create}}: Creates a ruby on rails app.
              Usage: {{command:%s app create [ rails | node | php ]}}
            HELP
            rails: {
              help: <<~HELP,
                {{command:%s app create rails}}: Creates a ruby on rails app.
                  Usage: {{command:%s app create rails}}
                  Options:
                    {{command:--name=NAME}} App name. Any string.
                    {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                    {{command:--store-domain=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
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
                yarn_version_failure: "Failed to get the current yarn version. Please make sure it is " \
                  "installed as per the instructions at https://classic.yarnpkg.com/en/docs/install.",
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
            node: {
              help: <<~HELP,
                {{command:%s app create node}}: Creates an embedded nodejs app.
                  Usage: {{command:%s app create node}}
                  Options:
                    {{command:--name=NAME}} App name. Any string.
                    {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                    {{command:--store-domain=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
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
            php: {
              help: <<~HELP,
                {{command:%s app create php}}: Creates an embedded PHP app.
                  Usage: {{command:%s app create php}}
                  Options:
                    {{command:--name=NAME}} App name. Any string.
                    {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                    {{command:--store-domain=MYSHOPIFYDOMAIN}} Development store URL. Must be an existing development store.
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
          },
          deploy: {
            help: <<~HELP,
            Deploy the current app to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
              Usage: {{command:%s app deploy [ heroku ]}}
            HELP
            extended_help: <<~HELP,
              {{bold:Subcommands:}}
                {{cyan:heroku}}: Deploys the current app to Heroku.
                  Usage: {{command:%s app deploy heroku}}
            HELP
            error: {
              missing_platform: <<~MESSAGE,
              The platform argument is missing.
                Usage: {{command:%s app deploy [ heroku ]}}
              MESSAGE
              invalid_platform: <<~MESSAGE,
              The platform argument passed {{command:%s}} is not supported.
                Usage: {{command:%s app deploy [ heroku ]}}
              MESSAGE
            },
            heroku: {
              downloading: "Downloading Heroku CLI…",
              downloaded: "Downloaded Heroku CLI",
              installing: "Installing Heroku CLI…",
              installing_windows: "Running Heroku CLI install wizard…",
              installed: "Installed Heroku CLI",
              authenticated_with_account: "{{v}} Authenticated with Heroku as {{green:%s}}",
              authenticating: "Authenticating with Heroku…",
              authenticated: "{{v}} Authenticated with Heroku",
              deploying: "Deploying to Heroku…",
              deployed: "{{v}} Deployed to Heroku",
              php: {
                post_deploy: <<~DEPLOYED,
                {{v}} Deployed to Heroku, you can access your app at {{green:%s}}

                  If you're deploying this app for the first time, make sure to set up your database and your app's environment at {{bold:App dashboard -> Settings -> Config Vars}}.

                  When setting your config vars, don't forget to set up your database and the appropriate Laravel values for it, particularly {{bold:DB_CONNECTION and DB_DATABASE}}.
                DEPLOYED
                error: {
                  generate_app_key: "Failed to generate Laravel APP_KEY",
                },
              },
              rails: {
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
                setting_configs: "Setting Shopify app configs…",
                configs_set: "{{v}} Shopify app configs set",
              },
            },
          },
          connect: {
            help: <<~HELP,
            {{command:%s app connect}}: Connects an existing app to Shopify CLI. Creates a config file.
              Usage: {{command:%s app connect}}
            HELP
            connected: "Project now connected to {{green:%s}}",
            production_warning: <<~MESSAGE,
              {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
            MESSAGE
          },
          tunnel: {
            help: <<~HELP,
              Start or stop an http tunnel to your local development app using ngrok.
                Usage: {{command:%s app tunnel [ auth | start | stop ]}}
            HELP
            extended_help: <<~HELP,
              {{bold:Subcommands:}}

                {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
                  Usage: {{command:%1$s app tunnel auth <token>}}

                {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
                  Usage: {{command:%1$s app tunnel start}}

                {{cyan:stop}}: Stops the ngrok tunnel.
                  Usage: {{command:%1$s app tunnel stop}}

            HELP
            error: {
              token_argument_missing: "{{x}} {{red:auth requires a token argument}}\n\n",
            },
          },
          serve: {
            help: <<~HELP,
              Start a local development server for your project, as well as a public ngrok tunnel to your localhost.
                Usage: {{command:%s app serve}}
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
            error: {
              host_must_be_https: "HOST must be a HTTPS url.",
              invalid_port: "%s is not a valid port.",
            },
          },
          open: {
            help: <<~HELP,
              Open your local development app in the default browser.
                Usage: {{command:%s app open}}
              HELP
          },
        },
        error_reporting: {
          unhandled_error: {
            message: "{{x}} {{red:An unexpected error occured.}}",
            issue_message: "{{red:\tTo \e]8;;%s\e\\submit an issue\e]8;;\e\\"\
              " include the stack trace.}}",
            stacktrace_message: "{{red:\tTo print the stack trace, add the environment variable %s.}}",
          },
          report_error: {
            question: "Send an anonymized error report to Shopify?",
            yes: "Yes, send",
            no: "No, don't send",
          },
        },
        analytics: {
          enable_prompt: {
            uncaught_error: {
              question: "Automatically send reports from now on?",
              yes: "Yes, automatically send anonymized reports to Shopify",
              no: "No, don't send",
            },
            usage: {
              question: "Automatically send anonymized usage and error reports to Shopify? We use these"\
                " to make development on Shopify better.",
              yes: "Yes, automatically send anonymized reports to Shopify",
              no: "No, don't send",
            },
          },
        },
        connect: {
          already_connected_warning: "{{yellow:! This app appears to be already connected}}",
          project_type_select: "What type of project would you like to connect?",
          cli_yml_saved: ".shopify-cli.yml saved to project root",
        },

        context: {
          open_url: <<~OPEN,
            Please open this URL in your browser:
            {{green:%s}}
          OPEN
        },

        env_file: {
          saving_header: "writing %s file…",
          saving: "writing %s file",
          saved: "%s saved to project root",
        },

        config: {
          help: <<~HELP,
            Change configuration of how the CLI operates
              Usage: {{command:%s config [ feature | analytics ] }}
          HELP
          feature: {
            help: <<~HELP,
              Change configuration of various features
                Usage: {{command:%s config [ feature ] [ feature_name ] }}
            HELP
            enabled: "{{v}} feature {{green:%s}} has been enabled",
            disabled: "{{v}} feature {{green:%s}} has been disabled",
            is_enabled: "{{v}} feature {{green:%s}} is currently enabled",
            is_disabled: "{{v}} feature {{green:%s}} is currently disabled",
          },
          analytics: {
            help: <<~HELP,
              Opt in/out of anonymous usage reporting
                Usage: {{command:%s config [ analytics ] }}
            HELP
            enabled: "{{v}} analytics have been enabled",
            disabled: "{{v}} analytics have been disabled",
            is_enabled: "{{v}} analytics are currently enabled",
            is_disabled: "{{v}} analytics are currently disabled",
          },
        },

        git: {
          error: {
            directory_exists: "Project directory already exists. Please create a project with a new name.",
            no_branches_found: "Could not find any git branches",
            repo_not_initiated:
              "Git repo is not initiated. Please run {{command:git init}} and make at least one commit.",
            no_commits_made: "No git commits have been made. Please make at least one commit.",
            remote_not_added: "Remote could not be added.",
            sparse_checkout_not_enabled: "Sparse checkout could not be enabled.",
            sparse_checkout_not_set: "Sparse checkout set command failed.",
            pull_failed: "Pull failed.",
            pull_failed_bad_branch: "Pull failed. Branch %s cannot be found. Check the branch name and try again.",
          },

          cloning: "Cloning %s into %s…",
          cloned: "{{v}} Cloned into %s",
          pulling_from_to: "Pulling %s into %s…",
          pulling: "Pulling…",
          pulled: "Pulled into %s",
        },

        help: {
          error: {
            command_not_found: "Command %s not found.",
          },

          preamble: <<~MESSAGE,
            Use {{command:%s help <command>}} to display detailed information about a specific command.

          MESSAGE
        },

        heroku: {
          error: {
            authentication: "Could not authenticate with Heroku",
            creation: "Heroku app could not be created",
            deploy: "Could not deploy to Heroku",
            download: "Heroku CLI could not be downloaded",
            install: "Could not install Heroku CLI",
            could_not_select_app: "Heroku app {{green:%s}} could not be selected",
            set_config: "Failed to set config %s to %s in Heroku app",
            add_buildpacks: "Failed to add buildpacks in Heroku app",
          },
        },

        js_deps: {
          error: {
            missing_package: "expected to have a file at: %s",
            invalid_package: "{{info:%s}} was not valid JSON. Fix this then try again",
            install_spinner_error: "Unable to install all %d dependencies",
            install_error: "An error occurred while installing dependencies",
          },

          installing: "Installing dependencies with %s…",
          installed: "Dependencies installed",
          npm_installing_deps: "Installing %d dependencies…",
          npm_installed_deps: "%d npm dependencies installed",
        },

        login: {
          help: <<~HELP,
            Log in to the Shopify CLI by authenticating with a store or partner organization
              Usage: {{command:%s login [--store=STORE]}}
          HELP
          invalid_shop: <<~MESSAGE,
            Invalid store provided (%s). Please provide the store in the following format: my-store.myshopify.com
          MESSAGE
          shop_prompt: <<~PROMPT,
            What store are you connecting to? (e.g. my-store.myshopify.com; do {{bold:NOT}} include protocol part, e.g., https://)
          PROMPT
        },

        logout: {
          help: <<~HELP,
            Log out of an authenticated partner organization and store, or clear invalid credentials
              Usage: {{command:%s logout}}
          HELP

          success: "Successfully logged out of your account",
        },

        switch: {
          help: <<~HELP,
            Switch between development stores in your partner organization
              Usage: {{command:%s switch [--store=STORE]}}
          HELP
          disabled_as_shopify_org: "Can't switch development stores logged in as {{green:Shopify partners org}}",
          success: "Switched development store to {{green:%s}}",
        },
        identity_auth: {
          error: {
            timeout: "Timed out while waiting for response from Shopify",
            local_identity_not_running: "Identity needs to be running locally in order to proceed.",
            reauthenticate: "Please login again with {{command:shopify login}}",
            invalid_destination: "The store %s doesn't exist. Please log out and try again.",
          },

          location: {
            admin: "development store",
            partner: "Shopify Partners account",
            shopifolk: "{{green:Shopify Employee account}}",
          },
          authentication_required:
            "{{i}} Authentication required. Login to the URL below with your %s credentials to continue.",

          servlet: {
            success_response: "Authenticated successfully. You may now close this page.",
            invalid_request_response: "Invalid request: %s",
            invalid_state_response: "Anti-forgery state token does not match the initial request.",
            authenticated: "Authenticated successfully",
            not_authenticated: "Failed to authenticate",
          },
          login_prompt: "Please ensure you've logged in with {{command:%s login}} and try again",
        },

        options: {
          help_text: "Print help for command",
        },

        partners_api: {
          org_name_and_id: "%s (%s)",
          error: {
            account_not_found: <<~MESSAGE,
              {{x}} error: Your account was not found. Please sign up at https://partners.shopify.com/signup
              For authentication issues, run {{command:%s logout}} to clear invalid credentials
            MESSAGE
          },
        },

        php_deps: {
          error: {
            missing_package: "Expected to have a file at: %s",
            invalid_package: "{{info:%s}} was not valid JSON. Fix this then try again",
            install: "Failed to install %s packages",
            install_spinner_error: "Unable to install all %d dependencies",
            install_error: "An error occurred while installing dependencies",
          },

          installing: "Installing Composer dependencies…",
          installed: "Dependencies installed",
          installed_count: "%d dependencies installed",
        },

        api: {
          error: {
            failed_auth: "Failed to authenticate with Shopify. Please try again later.",
            failed_auth_debugging: "{{red:Please provide this information with your report:}}\n%s\n\n",
            forbidden: <<~FORBIDDEN,
              Command not allowed with current login. Please check your login details with {{command:%s whoami}}. You may need to request additional permissions for this action.
            FORBIDDEN
            internal_server_error: "{{red:{{x}} An unexpected error occurred on Shopify.}}",
            internal_server_error_debug: "\n{{red:Response details:}}\n%s\n\n",
            invalid_url: "Invalid URL: %s",
          },
        },

        populate: {
          help: <<~HELP,
            Populate a Shopify store with example customers, orders, or products.
              Usage: {{command:%s populate [ customers | draftorders | products ]}}
          HELP

          extended_help: <<~HELP,
            {{bold:Subcommands:}}

              {{cyan:customers [options]}}: Add dummy customers to the specified store.
                Usage: {{command:%1$s populate customers}}

              {{cyan:draftorders [options]}}: Add dummy orders to the specified store.
                Usage: {{command:%1$s populate draftorders}}

              {{cyan:products [options]}}: Add dummy products to the specified store.
                Usage: {{command:%1$s populate products}}

            {{bold:Options:}}

              {{cyan:--count [integer]}}: The number of dummy items to populate. Defaults to 5.
              {{cyan:--silent}}: Silence the populate output.
              {{cyan:--help}}: Display more options specific to each subcommand.

            {{bold:Examples:}}

              {{command:%1$s populate products}}
                Populate your store with 5 additional products.

              {{command:%1$s populate customers --count 30}}
                Populate your store with 30 additional customers.

              {{command:%1$s populate draftorders}}
                Populate your store with 5 additional orders.

              {{command:%1$s populate products --help}}
                Display the list of options available to customize the {{command:%1$s populate products}} command.
          HELP

          error: {
            no_shop: "No store found. Please run {{command:%s login --store=STORE}} to login to a specific store",
          },

          customer: {
            added: "%s added to {{green:%s}} at {{underline:%scustomers/%d}}",
          },

          draft_order: {
            added: "DraftOrder added to {{green:%s}} at {{underline:%sdraft_orders/%d}}",
          },

          options: {
            header: "{{bold:{{cyan:%s}} options:}}",
            count_help: "Number of resources to generate",
          },

          populating: "Populating %d %ss…",

          completion_message: <<~COMPLETION_MESSAGE,
            Successfully added %d %s to {{green:%s}}
            {{*}} View all %ss at {{underline:%s%ss}}
          COMPLETION_MESSAGE

          product: {
            added: "%s added to {{green:%s}} at {{underline:%sproducts/%d}}",
          },
        },

        project: {
          error: {
            not_in_project: <<~MESSAGE,
              {{x}} You are not in a Shopify app project
              {{yellow:{{*}}}}{{reset: Run}}{{cyan: shopify app create}}{{reset: to create your app}}
            MESSAGE
          },
        },

        yaml: {
          error: {
            not_hash: "{{x}} %s was not a proper YAML file. Expecting a hash.",
            invalid: "{{x}} %s contains invalid YAML: %s",
            not_found: "{{x}} %s not found",
          },
        },

        project_type: {
          error: {
            cannot_override_core: "Can't register duplicate core command '%s' from %s",
          },
        },

        system: {
          help: <<~HELP,
            Print details about the development system.
              Usage: {{command:%s system [all]}}

            {{cyan:all}}: displays more details about development system and environment

          HELP

          error: {
            unknown_option: "{{x}} {{red:unknown option '%s'}}",
          },

          header: "{{bold:Shopify CLI}}",
          shop_header: "{{bold:Current Shop}}",
          const: "%17s = %s",
          ruby_header: <<~RUBY_MESSAGE,
            {{bold:Ruby (via RbConfig)}}
              %s
          RUBY_MESSAGE
          rb_config: "%-25s - RbConfig[\"%s\"]",
          command_header: "{{bold:Commands}}",
          command_with_path: "{{v}} %s, %s",
          command_not_found: "{{x}} %s",
          ngrok_available: "{{v}} ngrok, %s",
          ngrok_not_available: "{{x}} ngrok NOT available",
          project: {
            header: "{{bold:In a {{cyan:%s}} project directory}}",
            command_with_path: "{{v}} %s, %s, version %s",
            command_not_found: "{{x}} %s",
            env_header: "{{bold:Project environment}}",
            env_not_set: "not set",
            env: "%-18s = %s",
            no_env: "{{x}} .env file not present",
          },
          environment_header: "{{bold:Environment}}",
          env: "%-17s = %s",
          identity_header: "{{bold:Identity}}",
          identity_is_shopifolk: "{{v}} Checked user settings: you’re Shopify staff!",
        },

        store: {
          help: <<~HELP,
            Display current store.
              Usage: {{command:%s store}}
          HELP
          shop: "You're currently logged into {{green:%s}}",
        },

        tasks: {
          confirm_store: {
            prompt: "You are currently logged into {{green:%s}}. Do you want to proceed using this store?",
            confirmation: "Proceeding using {{green:%s}}",
            cancelling: "Cancelling…",
          },
          ensure_env: {
            organization_select: "To which partner organization does this project belong?",
            no_development_stores: <<~MESSAGE,
              No development stores available.
              Visit {{underline:https://partners.shopify.com/%d/stores}} to create one
            MESSAGE
            development_store_select: "Which development store would you like to use?",
            app_select: "To which app does this project belong?",
            no_apps: "You have no apps to connect to, creating a new app.",
            app_name: "App name",
            app_type: {
              select: "What type of app are you building?",
              select_public: "Public: An app built for a wide merchant audience.",
              select_custom: "Custom: An app custom built for a single client.",
              selected: "App type {{green:%s}}",
            },
          },
          ensure_dev_store: {
            could_not_verify_store: "Couldn't verify your store %s",
            convert_to_dev_store: <<~MESSAGE,
              Do you want to convert %s to a development store?
              Doing this will allow you to install your app, but the store will become {{bold:transfer-disabled}}.
              Learn more: https://shopify.dev/tutorials/transfer-a-development-store-to-a-merchant#transfer-disabled-stores
              MESSAGE
            transfer_disabled: "{{v}} Transfer has been disabled on %s.",
          },
          ensure_project_type: {
            wrong_project_type: "This command can only be run within %s projects.",
          },
          update_dashboard_urls: {
            updated: "{{v}} Whitelist URLS updated in Partners Dashboard}}",
            update_error:
              "{{x}} error: For authentication issues, run {{command:%s logout}} to clear invalid credentials",
            update_prompt: "Do you want to update your application url?",
          },
          select_org_and_shop: {
            authentication_issue: "For authentication issues, run {{command:%s logout}} to clear invalid credentials",
            create_store: "Visit {{underline:https://partners.shopify.com/%s/stores}} to create one",
            development_store: "Using development store {{green:%s}}",
            development_store_select: "Select a development store",
            error: {
              no_development_stores: "{{x}} No Development Stores available.",
              no_organizations: "No partner organizations available.",
              organization_not_found: "Cannot find a partner organization with that ID",
              shopifolk_notice: <<~MESSAGE,
                {{i}} As a {{green:Shopify}} employee, the authentication should take you to the Shopify Okta login,
                NOT the partner account login. Please run {{command:%s logout}} and try again.
              MESSAGE
            },
            first_party: "Are you working on a {{green:Shopify project}} on behalf of the"\
              " {{green:Shopify partners org}}?",
            identified_as_shopify: "We've identified you as a {{green:Shopify}} employee.",
            organization: "Partner organization {{green:%s (%s)}}",
            organization_select: "Select partner organization",
          },
        },

        tunnel: {
          error: {
            stop: "ngrok tunnel could not be stopped. Try running {{command:killall -9 ngrok}}",
            url_fetch_failure: "Unable to fetch external url",
            prereq_command_required: "%1$s is required for installing ngrok. Please install %1$s using the appropriate"\
              " package manager for your system.",
            ngrok: "Something went wrong with ngrok installation,"\
              "please make sure %s exists within %s before trying again",
          },
          installing: "Installing ngrok…",
          not_running: "{{green:x}} ngrok tunnel not running",
          prereq_command_location: "%s @ %s",
          signup_suggestion: <<~MESSAGE,
            {{*}} To avoid tunnels that timeout, it is recommended to signup for a free ngrok
            account at {{underline:https://ngrok.com/signup}}. After you signup, install your
            personalized authorization token using {{command:%s [ node | rails ] tunnel auth <token>}}.
          MESSAGE
          start: "{{v}} ngrok tunnel running at {{underline:%s}}",
          start_with_account: "{{v}} ngrok tunnel running at {{underline:%s}}, with account %s",
          stopped: "{{green:x}} ngrok tunnel stopped",
          timed_out: "{{x}} ngrok tunnel has timed out, restarting…",
          will_timeout: "{{*}} This tunnel will timeout in {{red:%s}}",
        },

        version: {
          help: <<~HELP,
            Prints version number.
              Usage: {{command:%s version}}
          HELP
        },

        warning: {
          development_version: <<~DEVELOPMENT,
            {{*}} {{yellow:You are running a development version of the CLI at:}}
              {{yellow:%s}}

          DEVELOPMENT

          new_version: <<~MESSAGE,
            {{*}} {{yellow:A new version of Shopify CLI is available! You have version %s and the latest version is %s.

              To upgrade, follow the instructions for the package manager you’re using:
              {{underline:https://shopify.dev/tools/cli/troubleshooting#upgrade-shopify-cli}}}}

          MESSAGE
        },
        reporting: {
          help: <<~HELP,
            Turns anonymous reporting on or off.
              Usage: {{command:%s reporting on}}
          HELP
          invalid_argument: <<~MESSAGE,
            {{command:%s reporting %s}} is not supported. The valid values are {{command:on}} or {{command:off}}
          MESSAGE
          missing_argument: <<~MESSAGE,
            {{command:%s reporting}} expects an argument {{command:on}} or {{command:off}}
          MESSAGE
          turned_on_message: <<~MESSAGE,
            Anonymized reports will be sent to Shopify.
          MESSAGE
          turned_off_message: <<~MESSAGE,
            Turn on automatic reporting later wtih {{command:%s reporting on}}.
          MESSAGE
        },
        whoami: {
          help: <<~HELP,
            Identifies which partner organization or store you are currently logged into.
              Usage: {{command:%s whoami}}
          HELP
          not_logged_in: <<~MESSAGE,
            It doesn't appear that you're logged in. You must log into a partner organization or a store staff account.

            If trying to log into a store staff account, please use {{command:%s login --store=STORE}} to log in.
          MESSAGE
          logged_in_shop_only: <<~MESSAGE,
            Logged into store {{green:%s}} as staff (no partner organizations available for this login)
          MESSAGE
          logged_in_partner_only: "Logged into partner organization {{green:%s}}",
          logged_in_partner_and_shop: "Logged into store {{green:%s}} in partner organization {{green:%s}}",
        },
      },
    }.freeze
  end
end
