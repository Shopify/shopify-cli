# frozen_string_literal: true

module Script
  module Messages
    MESSAGES = {
      script: {
        error: {
          generic: "{{red:{{x}} Error}}",
          eacces_cause: "You don't have permission to write to this directory.",
          eacces_help: "Change your directory permissions and try again.",

          enospc_cause: "You don't have enough disk space to perform this action.",
          enospc_help: "Free up some space and try again.",

          oauth_cause: "Something went wrong while authenticating your account with the Partner Dashboard.",
          oauth_help: "Try again.",

          invalid_context_cause: "Your .shopify-cli.yml file is not correct.",
          invalid_context_help: "See https://help.shopify.com",

          no_existing_apps_cause: "You don't have any apps.",
          no_existing_apps_help: "Please create an app with {{command:shopify create}} or"\
                                 "visit https://partners.shopify.com/.",

          no_existing_orgs_cause: "You don't have any organizations.",
          no_existing_orgs_help: "Please visit https://partners.shopify.com/ to create a partners account.",

          no_existing_stores_cause: "You don't have any development stores.",
          no_existing_stores_help: "Visit https://partners.shopify.com/%{organization_id}/stores/ to create one.",

          project_exists_cause: "Directory with the same name as the script already exists.",
          project_exists_help: "Use different script name and try again.",

          invalid_extension_cause: "Invalid extension point %s",
          invalid_extension_help: "Allowed values: discount and unit_limit_per_order.",

          script_not_found_cause: "Couldn't find script %s for extension point %s",

          app_not_installed_cause: "App not installed on development store.",

          app_script_undefined_help: "Deploy script to app.",

          build_error_cause: "Something went wrong while building the script.",
          build_error_help: "Correct the errors and try again.",

          dependency_install_cause: "Something went wrong while installing the dependencies that are needed.",
          dependency_install_help: "See https://help.shopify.com",

          forbidden_error_cause: "You do not have permission to do this action.",

          graphql_error_cause: "An error was returned: %s.",
          graphql_error_help: "\nReview the error and try again.",

          script_redeploy_cause: "Script with the same extension point already exists on app (API key: %s).",
          script_redeploy_help: "Use {{cyan:--force}} to replace the existing script.",

          shop_auth_cause: "Unable to authenticate with the store.",
          shop_auth_help: "Try again.",

          shop_script_conflict_cause: "Another app in this store has already enabled a script "\
                                      "on this extension point.",
          shop_script_conflict_help: "Disable that script or uninstall that app and try again.",

          shop_script_undefined_cause: "Script is already turned off in development store.",

          test_help: "Correct the errors and try again.",
        },

        create: {
          help: <<~HELP,
          {{command:%1$s create script}}: Creates a script project.
            Usage: {{command:%1$s create script}}
            Options:
              {{command:--name=NAME}} Script project name. Any string.
              {{command:--extension_point=TYPE}} Extension point name. Allowed values: %2$s.
          HELP

          error: {
            operation_failed: "Script not created.",
          },

          changed_dir: "{{v}} Changed to project directory: {{green:%{folder}}}",
          script_created: "{{v}} Script created: {{green:%{script_id}}}",
          creating: "Creating script",
          created: "Created script",
        },

        deploy: {
          help: <<~HELP,
          Build the script and deploy it to app.
            Usage: {{command:%s deploy --API_key=<API_key> [--force]}}
          HELP

          error: {
            operation_failed: "Script not deployed.",
          },

          script_deployed: "{{v}} Script deployed to app (API key: %{api_key}).",
        },

        disable: {
          help: <<~HELP,
          Turn off script in development store.
            Usage: {{command:%s disable --API_key=<API_key> --shop_domain=<my_store.myshopify.com>}}
          HELP

          error: {
            operation_failed: "Can't disable script.",
          },

          script_disabled: "{{v}} Script disabled. Script is turned off in development store.",
        },

        enable: {
          help: <<~HELP,
          Turn on script in development store.
            Usage: {{command:%s enable --API_key=<API_key> --shop_domain=<my_store.myshopify.com>}}
          HELP

          error: {
            operation_failed: "Can't enable script.",
          },

          script_enabled: "{{v}} Script enabled. %{type} script %{title} in app (API key: %{api_key}) "\
                          "is turned on in development store {{green:%{shop_domain}}}",
        },

        project_deps: {
          deps_are_installed: "{{v}} Dependencies installed",
          installing_with_npm: "Installing dependencies with npm",
          installing: "Dependencies installing",
          installed: "Dependencies installed",
        },

        test: {
          help: <<~HELP,
          Runs unit tests on your script.
            Usage: {{command:%s test}}
          HELP

          error: {
            operation_failed: "Tests didn't run or they ran with failures.",
          },

          running: "Running tests",
          success: "{{v}} Tests finished.",
        },

        forms: {
          create: {
            select_extension_point: "Which extension point do you want to use?",
            script_name: "Script Name",
          },
          script_form: {
            ask_app_api_key_default: "Which app do you want this script to belong to?",
            ask_shop_domain_default: "Select a development store",
            fetching_organizations: "Fetching organizations",
            fetched_organizations: "Fetched organizations",
            select_organization: "Select organization.",
            using_app: "Using app {{green:%{title} (%{api_key})}}.",
            using_development_store: "Using development store {{green:%{domain}}}",
            using_organization: "Organization {{green:%s}}.",
          },
          enable: {
            ask_app_api_key: "Which app is the script deployed to?",
            ask_shop_domain: "Which development store is the app installed on?",
          },
        },

        application: {
          build_script: {
            building: "Building",
            building_script: "Building script",
            built: "Built",
          },
          deploy_script: {
            deploying: "Deploying",
            deployed: "Deployed",
          },
          disable_script: {
            disabling: "Disabling",
            disabled: "Disabled",
          },
          enable_script: {
            enabling: "Enabling",
            enabled: "Enabled",
          },
        },
      },
    }.freeze
  end
end
