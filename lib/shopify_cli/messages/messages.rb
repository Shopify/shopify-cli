# frozen_string_literal: true

module ShopifyCLI
  module Messages
    MESSAGES = {
      apps: {
        create: {
          info: {
            created: "{{v}} {{green:%s}} was created in the organization's Partner Dashboard {{underline:%s}}",
            serve: "{{*}} Change directories to your new project folder {{green:%s}} and run "\
            "{{command:%s %s serve}} to start a local server",
            install: "{{*}} Then, visit {{underline:%s/test}} to install {{green:%s}} on your Dev Store",
          },
        },
      },
      core: {
        error_reporting: {
          unhandled_error: {
            message: "{{x}} {{red:An unexpected error occured.}}",
            issue_message: "{{red:\tTo \e]8;;#{ShopifyCLI::Constants::Links::NEW_ISSUE}\e\\submit an issue\e]8;;\e\\"\
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
            question: "Automatically send reports from now on?",
            yes: "Yes, automatically send anonymized reports to Shopify",
            no: "No, don't send",
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
              {{yellow:{{*}}}}{{reset: Run}}{{cyan: shopify rails create}}{{reset: or}}{{cyan: shopify node create}}{{reset: to create your app}}
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
