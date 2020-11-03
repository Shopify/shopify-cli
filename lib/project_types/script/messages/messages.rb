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

          invalid_config_props_cause: "{{command:--config_props}} is formatted incorrectly.",
          invalid_config_props_help: "Try again using this format: "\
                                     "{{cyan:--config_props='name1:value1, name2:value2'}}",

          invalid_script_name_cause: "Invalid script name.",
          invalid_script_name_help: "Replace or remove unsupported characters. Valid characters "\
                                    "are numbers, letters, hyphens, or underscores.",

          no_existing_apps_cause: "You don't have any apps.",
          no_existing_apps_help: "Please create an app with {{command:shopify create}} or "\
                                 "visit https://partners.shopify.com/.",

          no_existing_orgs_cause: "You don't have any partner organizations.",
          no_existing_orgs_help: "Please visit https://partners.shopify.com/ to create a partners account.",

          no_existing_stores_cause: "You don't have any stores.",
          no_existing_stores_help: "Visit https://partners.shopify.com/%{organization_id}/stores/ to create one.",

          project_exists_cause: "Directory with the same name as the script already exists.",
          project_exists_help: "Use different script name and try again.",

          invalid_extension_cause: "Invalid extension point %s",
          invalid_extension_help: "Allowed values: %s.",

          invalid_config: "Can't change the configuration values because %1$s is missing or "\
                          "it is not formatted properly.",

          script_not_found_cause: "Couldn't find script %s for extension point %s",

          app_not_installed_cause: "App not installed on store.",

          app_script_not_pushed_help: "Script isn't on the app. Run {{command:shopify push}}, and then try again.",

          build_error_cause: "Something went wrong while building the script.",
          build_error_help: "Correct the errors and try again.",

          dependency_install_cause: "Something went wrong while installing the dependencies that are needed.",
          dependency_install_help: "Correct the errors and try again.",

          forbidden_error_cause: "You do not have permission to do this action.",

          graphql_error_cause: "An error was returned: %s.",
          graphql_error_help: "\nReview the error and try again.",

          script_repush_cause: "A script with the same extension point already exists on app (API key: %s).",
          script_repush_help: "Use {{cyan:--force}} to replace the existing script.",

          shop_auth_cause: "Unable to authenticate with the store.",
          shop_auth_help: "Try again.",

          shop_script_conflict_cause: "Another app in this store has already enabled a script "\
                                      "on this extension point.",
          shop_script_conflict_help: "Disable that script or uninstall that app and try again.",

          shop_script_undefined_cause: "Script is already turned off in store.",

          packages_outdated_cause: "The following npm packages are out of date: %s.",
          packages_outdated_help: "Update them by running {{cyan:npm install --save-dev %s}}.",
        },

        create: {
          help: <<~HELP,
          {{command:%1$s create script}}: Creates a script project.
            Usage: {{command:%1$s create script}}
            Options:
              {{command:--name=NAME}} Script project name. Use any string.
              {{command:--extension_point=TYPE}} Extension point name. Allowed values: %2$s.
          HELP

          error: {
            operation_failed: "Script not created.",
          },

          change_directory_notice: "{{*}} Change directories to {{green:%s}} to run script commands",
          creating: "Creating script",
          created: "Created script: {{green:%s}}",
        },

        push: {
          help: <<~HELP,
          Build the script and put it into production. If you've already pushed a script with the same extension point, use --force to replace the current script with the newest one.
            Usage: {{command:%s push}}
            Options:
              {{command:[--force]}} Forces the script to be overwritten if an instance of it already exists.
          HELP

          error: {
            operation_failed: "Couldn't push script to app.",
          },

          script_pushed: "{{v}} Script pushed to app (API key: %{api_key}).",
        },

        disable: {
          help: <<~HELP,
          Turn off script in store.
            Usage: {{command:%s disable}}
          HELP

          error: {
            operation_failed: "Can't disable script.",
          },

          script_disabled: "{{v}} Script disabled. Script is turned off in store.",
        },

        enable: {
          help: <<~HELP,
          Turn on script in store.
            Usage: {{command:%s enable}}
            Options:
              {{command:--config_props='name1:value1, name2:value2'}} Optional. Define the configuration of your script by passing individual name and value pairs. If used with --config_file, then matching values in --config_props will override those set in the file.
              {{command:--config_file=<path/to/YAMLFilename>}} Optional. Define the configuration of your script using a YAML formatted file. --config_props values override properties in this file.
          HELP

          info: "{{*}} A script always remains enabled until you disable it - even after pushing "\
                "script changes with the same extension point to an app. To disable a script, use "\
                "the 'disable' command.",

          error: {
            operation_failed: "Can't enable script.",
          },

          script_enabled: "{{v}} Script enabled. %{type} script %{title} in app (API key: %{api_key}) "\
                          "is turned on in store {{green:%{shop_domain}}}",
        },

        project_deps: {
          none_required: "{{v}} None required",
          checking_with_npm: "Checking dependencies with npm",
          installing: "Dependencies installing",
          installed: "Missing dependencies installed",
        },

        forms: {
          create: {
            select_extension_point: "Which extension point do you want to use?",
            script_name: "Script Name",
          },
        },

        application: {
          building: "Building",
          building_script: "Building script",
          built: "Built",
          pushing: "Pushing",
          pushed: "Pushed",
          disabling: "Disabling",
          disabled: "Disabled",
          enabling: "Enabling",
          enabled: "Enabled",
        },
      },
    }.freeze
  end
end
