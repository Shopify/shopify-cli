# frozen_string_literal: true

module ShopifyCli
  module Messages
    MESSAGES = {
      apps: {
        create: {
          info: {
            created: "{{v}} {{green:%s}} was created in your Partner Dashboard {{underline:%s}}",
            serve: "{{*}} Change directories to your new project folder {{green:%s}} and run {{command:%s serve}} " \
            "to start a local server",
            install: "{{*}} Then, visit {{underline:%s/test}} to install {{green:%s}} on your Dev Store",
          },
        },
      },
      core: {
        connect: {
          help: <<~HELP,
          Connect (or re-connect) an existing project to a Shopify partner organization and/or a store. Creates or updates the {{green:.env}} file, and creates the {{green:.shopify-cli.yml}} file.
            Usage: {{command:%s connect}}
          HELP

          production_warning: <<~MESSAGE,
          {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
          MESSAGE
          already_connected_warning: "{{yellow:! This app appears to be already connected}}",
          connected: "{{v}} Project now connected to {{green:%s}}",
          project_type_select: "What type of project would you like to connect?",
          cli_yml_saved: ".shopify-cli.yml saved to project root",
        },

        context: {
          open_url: <<~OPEN,
          Please open this URL in your browser:
          {{green:%s}}
          OPEN
        },

        create: {
          help: <<~HELP,
          Create a new project.
            Usage: {{command:%s create [ %s ]}}
          HELP

          error: {
            invalid_app_type: "{{red:Error}}: invalid app type {{bold:%s}}",
          },

          project_type_select: "What type of project would you like to create?",
        },

        env_file: {
          saving_header: "writing %s file...",
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
            repo_not_initiated: "Git repo is not initiated. Please run `git init` and make at least one commit.",
            no_commits_made: "No git commits have been made. Please make at least one commit.",
          },

          cloning: "Cloning %s into %s...",
          cloned: "{{v}} Cloned into %s",
        },

        help: {
          error: {
            command_not_found: "Command %s not found.",
          },

          preamble: <<~MESSAGE,
          Use {{command:%s help <command>}} to display detailed information about a specific command.

          {{bold:Available core commands:}}

          MESSAGE
        },

        heroku: {
          error: {
            authentication: "Could not authenticate with Heroku",
            creation: "Heroku app could not be created",
            deploy: "Could not deploy to Heroku",
            download: "Heroku CLI could not be downloaded",
            install: "Could not install Heroku CLI",
            could_not_select_app: "Heroku app `%s` could not be selected",
          },
        },

        js_deps: {
          error: {
            missing_package: "expected to have a file at: %s",
            invalid_package: "{{info:%s}} was not valid JSON. Fix this then try again",
            install_spinner_error: "Unable to install all %d dependencies",
            install_error: 'An error occurred while installing dependencies',
          },

          installing: "Installing dependencies with %s...",
          installed: "Dependencies installed",
          npm_installing_deps: "Installing %d dependencies...",
          npm_installed_deps: "%d npm dependencies installed",
        },

        logout: {
          help: <<~HELP,
          Log out of a currently authenticated partner organization and store, or clear invalid credentials
            Usage: {{command:%s logout}}
          HELP

          success: "Logged out of partner organization and store",
        },

        monorail: {
          consent_prompt: <<~MSG,
            Would you like to enable anonymous usage reporting?
            If you select “Yes”, we’ll collect data about which commands you use and which errors you encounter.
            Sharing this anonymous data helps Shopify improve this tool.
          MSG
        },

        oauth: {
          error: {
            timeout: "Timed out while waiting for response from Shopify",
          },

          location: {
            admin: "development store",
            partner: "Shopify Partners account",
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

        api: {
          error: {
            internal_server_error: '{{red:{{x}} An unexpected error occurred on Shopify.}}',
            internal_server_error_debug: "\n{{red:Response details:}}\n%s\n\n",
          },
        },

        populate: {
          options: {
            header: "{{bold:{{cyan:%s}} options:}}",
            count_help: "Number of resources to generate",
          },
          populating: "Populating %d %ss...",
          completion_message: <<~COMPLETION_MESSAGE,
          Successfully added %d %s to {{green:%s}}
          {{*}} View all %ss at {{underline:%s%ss}}
          COMPLETION_MESSAGE
        },

        project: {
          error: {
            not_in_project: <<~MESSAGE,
            {{x}} You are not in a Shopify app project
            {{yellow:{{*}}}}{{reset: Run}}{{cyan: shopify create}}{{reset: to create your app}}
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

          header: "{{bold:Shopify App CLI}}",
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

        tasks: {
          ensure_env: {
            organization_select: "To which partner organization does this project belong?",
            no_development_stores: <<~MESSAGE,
            No development stores available.
            Visit {{underline:https://partners.shopify.com/%d/stores}} to create one
            MESSAGE
            development_store_select: "Which development store would you like to use?",
            app_select: "To which app does this project belong?",
            no_apps: 'You have no apps to connect to, creating a new app.',
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
              partners_notice: "Please visit https://partners.shopify.com/ to create a partners account",
            },
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
          },

          not_running: "{{green:x}} ngrok tunnel not running",
          signup_suggestion: <<~MESSAGE,
          {{*}} To avoid tunnels that timeout, it is recommended to signup for a free ngrok
          account at {{underline:https://ngrok.com/signup}}. After you signup, install your
          personalized authorization token using {{command:%s tunnel auth <token>}}.
          MESSAGE
          start: "{{v}} ngrok tunnel running at {{underline:%s}}",
          start_with_account: "{{v}} ngrok tunnel running at {{underline:%s}}, with account %s",
          stopped: "{{green:x}} ngrok tunnel stopped",
          timed_out: "{{x}} ngrok tunnel has timed out, restarting ...",
          will_timeout: "{{*}} This tunnel will timeout in {{red:%s}}",
          prereq_command_location: "%s @ %s",
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

          shell_shim: <<~MESSAGE,
          {{x}} This version of Shopify App CLI is no longer supported. You’ll need to migrate to the new CLI version to continue.

            Please visit this page for complete instructions:
            {{underline:https://shopify.github.io/shopify-app-cli/migrate/}}

          MESSAGE

          new_version: <<~MESSAGE,
          {{*}} {{yellow:A new version of the Shopify App CLI is available! You have version %s and the latest version is %s.

            To upgrade, follow the instructions for the package manager you’re using:
            {{underline:https://shopify.github.io/shopify-app-cli/getting-started/upgrade/}}}}

          MESSAGE
        },
      },
    }.freeze
  end
end
