# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Messages
    MESSAGES = {
      extension: {
        help: <<~HELP,
          Suite of commands for developing app extensions. See {{command:%1$s extension <command> --help}} for usage of each command.
            Usage: {{command:%1$s extension [ %2$s ]}}
        HELP
      },
      create: {
        help: <<~HELP,
          Create a new app extension.
            Usage: {{command:%s extension create <name>}}
            Options:
              {{command:--type=TYPE}} The type of extension you would like to create.
              {{command:--name=NAME}} The name of your extension (50 characters).
              {{command:--api-key=KEY}} The API key of your app.
        HELP
        ask_name: "Extension name",
        invalid_name: "Extension name must be under %s characters",
        ask_type: "What type of extension are you creating?",
        invalid_type: "Extension type is invalid.",
        setup_project_frame_title: "Initializing project",
        ready_to_start: <<~MESSAGE,
          {{v}} A new folder was generated at {{green:./%s}}.
          {{*}} You’re ready to start building {{green:%s}}!
          Navigate to the new folder, then run {{command:shopify extension serve}} to start a local server.
        MESSAGE
        learn_more: <<~MESSAGE,
          {{*}} Once you're ready to version and publish your extension,
          run {{command:shopify extension register}} to register this extension with one of your apps.
        MESSAGE
        try_again: "{{*}} Fix the errors and run {{command:shopify extension create}} again.",
        errors: {
          directory_exists: "Directory ‘%s’ already exists. Please remove it or choose a new name for your project.",
        },
        incomplete_configuration: "Cannot create extension due to missing configuration information",
        invalid_api_key: "The API key %s does not match any of your apps.",
        ask_app: "Which app would you like to register this extension with?",
        no_apps: "{{x}} You don’t have any apps.",
        learn_about_apps: "{{*}} Learn more about building apps at <https://shopify.dev/apps>, " \
          "or try creating a new app using {{command:shopify [node|rails] create}}.",
        loading_apps: "Loading your apps…",
        no_available_extensions: "{{x}} There are no available extensions for this app.",
        ask_template: "Select a template to use for your extension",
      },
      connect: {
        connected: "Project now connected to {{green:%s: %s}}",
        incomplete_configuration: "Cannot connect extension due to missing configuration information",
        invalid_api_key: "The API key %s does not match any of your apps.",
        ask_registration: "Which extension would you like to connect to?",
        loading_extensions: "Loading your extensions…",
        no_extensions: "{{x}} You don't have any extensions of type %s",
        learn_about_extensions: "{{*}} Learn more about building extensions at <https://shopify.dev/concepts/apps>, " \
          "or try creating a new extension using {{command:shopify extension create}}.",
        help: <<~HELP,
          {{command:%s extension connect}}: Connects an existing extension to Shopify CLI. Creates a config file.
            Usage: {{command:%s extension connect}}
        HELP
      },
      build: {
        help: <<~HELP,
          Build your extension to prepare for deployment.
            Usage: {{command:%s extension build}}
        HELP
        frame_title: "Building extension with: %s…",
        build_failure_message: "Failed to build extension code.",
      },
      register: {
        help: <<~HELP,
          Register your local extension to a Shopify app
              Usage: {{command:%s extension register}}
        HELP
        frame_title: "Registering Extension",
        waiting_text: "Registering with Shopify…",
        already_registered: "Extension is already registered.",
        confirm_info: "This will create a new extension registration for %s, which can’t be undone.",
        confirm_question: "Would you like to register this extension? (y/n)",
        confirm_abort: "Extension was not registered.",
        success: "{{v}} Registered {{green:%s}}.",
        success_info: "{{*}} Run {{command:shopify extension push}} to push your extension to Shopify.",
      },
      push: {
        help: <<~HELP,
          Push the current extension to Shopify.
            Usage: {{command:%s extension push}}
            Options:
              {{command:--api-key=API_KEY}} Connect your extension and app by inserting your app's API key (which you can get from your app setup page on shopify.dev).
              {{command:--extension-id=EXTENSION_ID}} The id of the extension's registration.
        HELP
        frame_title: "Pushing your extension to Shopify",
        waiting_text: "Pushing code to Shopify…",
        pushed_with_errors: "{{x}} Code pushed to Shopify with errors on %s.",
        push_with_errors_info: "{{*}} Fix these errors and run {{command:shopify extension push}} to " \
          "revalidate your extension.",
        success_confirmation: "{{v}} Pushed {{green:%s}} to a draft on %s.",
        success_info: "{{*}} Visit %s to version and publish your extension.",
      },
      serve: {
        help: <<~HELP,
          Serve your extension in a local simulator for development.
            Usage: {{command:%s extension serve [ ROOT ]}}
            Options:
              {{command:-p, --port=PORT}}             Local port of the development serve.
              {{command:-T, --theme=NAME_OR_ID}}      Theme ID or name of the host theme.
              {{command:--tunnel=TUNNEL}}             Establish an ngrok tunnel (default: false).
              {{command:--api-key=API_KEY}}           Connect your extension and app by inserting your app's API key (which you can get from your app setup page on shopify.dev).
              {{command:--api-secret=API_SECRET}}     The API secret of the app the script is registered with.
              {{command:--extension-id=EXTENSION_ID}} The id of the extension's registration.
        HELP
        frame_title: "Viewing extension…",
        no_available_ports_found: "No available ports found to run extension.",
        serve_failure_message: "Failed to run extension code.",
        serve_missing_information: "Missing shop or api_key.",
        tunnel_already_running: "A tunnel running on another port has been detected. Close the tunnel and try again.",
        preview_message: <<~PREVIEW_MESSAGE,
          Enable your theme app extension:
          {{green:%s}}

          Setup your theme app extension in the host theme:
          {{green:%s}}

          Preview your theme app extension:
          {{green:%s}}

          (Use Ctrl-C to stop)
        PREVIEW_MESSAGE
      },
      tunnel: {
        duplicate_session: <<~MESSAGE,
          Another ngrok tunnel is currently running with your auth token, possibly on another machine.

          Terminate that tunnel before opening a new one.
        MESSAGE
        invalid_token: <<~MESSAGE,
          The ngrok token currently configured is invalid.

          After generating a new token, update your local ngrok configuration using {{command:shopify app tunnel auth <token>}}
        MESSAGE
        missing_token: "{{x}} {{red:auth requires a token argument}}. "\
          "Find it on your ngrok dashboard: {{underline:https://dashboard.ngrok.com/auth/your-authtoken}}.",
        invalid_port: "%s is not a valid port.",
        no_tunnel_running: "No tunnel running.",
        tunnel_running_at: "Tunnel running at: {{underline:%s}}",
        help: <<~HELP,
          Start or stop an http tunnel to your local development extension using ngrok.
            Usage: {{command:%s extension tunnel [ auth | start | stop | status ]}}
        HELP
        extended_help: <<~HELP,
          {{bold:Subcommands:}}

            {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account.
            Visit https://dashboard.ngrok.com/signup to sign up.
              Usage: {{command:%1$s extension tunnel auth <token>}}

            {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
              Usage: {{command:%1$s extension tunnel start}}
              Options:
              {{command:--port=PORT}} Forward the ngrok subdomain to local port PORT. Defaults to %2$s.

            {{cyan:stop}}: Stops the ngrok tunnel.
              Usage: {{command:%1$s extension tunnel stop}}

            {{cyan:status}}: Output the current status of the ngrok tunnel.
              Usage: {{command:%1$s extension tunnel status}}
        HELP
      },
      check: {
        help: "Check your extension for errors, suggestions, and best practices.",
        unsupported: "{{red:%s projects are not supported for `extension check`}}",
      },
      features: {
        argo: {
          missing_file_error: "Could not find built extension file.",
          script_prepare_error: "An error occurred while attempting to prepare your script.",
          initialization_error: "{{x}} There was an error while initializing the project.",
          dependencies: {
            node: {
              node_not_installed: "Node must be installed to create this extension.",
              version_too_low: "Your node version %s does not meet the minimum required version %s",
            },
            argo_missing_renderer_package_error: "Extension template references invalid renderer package "\
              "please contact Shopify for help.",
            yarn_install_error: "Something went wrong while running 'yarn install'. %s.",
            yarn_run_script_error: "Something went wrong while running script. %s.",
          },
          config: {
            unpermitted_keys: "`%s` contains the following unpermitted keys: %s",
          },
        },
      },
      tasks: {
        errors: {
          parse_error: "Unable to parse response from Partners Dashboard.",
          store_error: "There was an error getting store data. Try again later.",
        },
      },
      errors: {
        unknown_type: "Unknown extension type %s. Valid extension types include: CHECKOUT_POST_PURCHASE, " \
        "THEME_APP_EXTENSION, and PRODUCT_SUBSCRIPTION.",
        package_not_found: "`%s` package not found.",
        missing_push_options_ci: "The following are missing: %s. ",
        missing_push_options_ci_solution: "To add them to a CI environment:\n\t1. Run a connect command " \
        "({{command:%1$s extension connect}})\n\t2. Navigate to the .env file at the root of your project\n\t" \
            "3. Copy the missing values and pass them through as arguments in {{command:%1$s extension push}}",
        missing_env_file_variables: "The following are missing in the .env file: %s. ",
        missing_env_file_variables_solution: "To add it, connect your extension with " \
        "{{command:%1$s extension connect}} " \
        "or run {{command:%1$s extension register}} to register a new extension.",
        module_not_found: "Unable to find module %s. Ensure your dependencies are up-to-date and try again.",
        development_server_binary_not_found: {
          title: "Development Server Binary Missing",
          message: <<~ERROR,
            The extension development server binary could not be found!

            If you're running a development version of the CLI, please run `rake extensions:install` to install it.
            Otherwise, please file a bug report via https://github.com/Shopify/shopify-cli/issues/new.
          ERROR
        },
        outdated_extensions: {
          unknown: <<~TEXT.strip,
            Please refer to the documentation for more information on how to upgrade your extension:
            https://shopify.dev/apps/app-extensions
          TEXT
          checkout_ui_extension: <<~TEXT.strip,
            Please update your package.json as follows:
            * Replace the development dependency @shopify/checkout-ui-extensions-run
              with @shopify/shopify-cli-extensions
            * Remove the start and server script
            * Add a develop script: shopify-cli-extensions develop
            * Change the build script to: shopify-cli-extensions build
          TEXT
          product_subscription: <<~TEXT.strip,
            Please update your package.json as follows:
            * Replace the development dependency @shopify/admin-ui-extensions-run
              with @shopify/shopify-cli-extensions
            * Remove the start and server script
            * Add a develop script: shopify-cli-extensions develop
            * Change the build script to: shopify-cli-extensions build
          TEXT
          checkout_post_purchase: <<~TEXT.strip,
            Please update your package.json as follows:
            * Replace the development dependency @shopify/checkout-ui-extensions-run
              with @shopify/shopify-cli-extensions
            * Remove the start and server script
            * Add a develop script: shopify-cli-extensions develop
            * Change the build script to: shopify-cli-extensions build
          TEXT
        },
      },
      warnings: {
        resource_url_auto_generation_failed: "{{*}} {{yellow:Warning:}} Unable to auto generate " \
        "the extension resource URL because %s does not have any products. " \
        "Please run {{bold:shopify populate products}} to generate sample products.",
      },
    }

    TYPES = {
      product_subscription: {
        name: "Product Subscription",
        tagline: "(limit 1 per app)",
        overrides: {
          register: {
            confirm_info: "You can only create one %s extension per app, which can’t be undone.",
          },
        },
      },
      checkout_post_purchase: {
        name: "Checkout Post Purchase",
      },
      theme_app_extension: {
        name: "Theme App Extension",
        tagline: "(limit 1 per app)",
        overrides: {
          register: {
            confirm_info: "You can only create one %s extension per app, which can’t be undone.",
          },
          create: {
            ready_to_start: <<~MESSAGE,
              {{v}} A new folder was generated at {{green:./%s}}.
              {{*}} You’re ready to start building {{green:%s}}!
            MESSAGE
          },

        },
      },
    }
  end
end
