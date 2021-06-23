# frozen_string_literal: true

module Script
  module Messages
    MESSAGES = {
      script: {
        error: {
          deprecated_ep: "This project uses an extension point %s which has been deprecated. "\
                         "This Script will no longer function in production.",
          deprecated_ep_cause: "Try using a different extension point.",
          generic: "{{red:{{x}} Error}}",
          eacces_cause: "You don't have permission to write to this directory.",
          eacces_help: "Change your directory permissions and try again.",

          enospc_cause: "You don't have enough disk space to perform this action.",
          enospc_help: "Free up some space and try again.",

          oauth_cause: "Something went wrong while authenticating your account with the Partner Dashboard.",
          oauth_help: "Try again.",

          invalid_context_cause: "Your .shopify-cli.yml file is not correct.",
          invalid_context_help: "See https://help.shopify.com",

          invalid_config_props_cause: "{{command:--config-props}} is formatted incorrectly.",
          invalid_config_props_help: "Try again using this format: "\
                                     "{{cyan:--config-props='name1:value1, name2:value2'}}",

          invalid_script_name_cause: "Invalid script name.",
          invalid_script_name_help: "Replace or remove unsupported characters. Valid characters "\
                                    "are numbers, letters, hyphens, or underscores.",

          no_existing_apps_cause: "You don't have any apps.",
          no_existing_apps_help: "Create an app with {{command:shopify create}} or "\
                                 "visit https://partners.shopify.com/.",

          no_existing_orgs_cause: "You don't have any partner organizations.",
          no_existing_orgs_help: "Visit https://partners.shopify.com/ to create a partners account.",

          no_existing_stores_cause: "You don't have any stores.",
          no_existing_stores_help: "Visit https://partners.shopify.com/%{organization_id}/stores/ to create one.",

          project_exists_cause: "Directory with the same name as the script already exists.",
          project_exists_help: "Use different script name and try again.",

          invalid_extension_cause: "Invalid extension point %s.",
          invalid_extension_help: "Allowed values: %s.",

          invalid_language_cause: "Invalid language %s.",
          invalid_language_help: "Allowed values: %s.",

          invalid_config: "Can't change the configuration values because %1$s is missing or "\
                          "it is not formatted properly.",

          missing_script_json_field_cause: "The script.json file is missing the required %s field.",
          missing_script_json_field_help: "Add the field and try again.",

          invalid_script_json_definition_cause: "The script.json file contains invalid JSON.",
          invalid_script_json_definition_help: "Fix the errors and try again.",

          no_script_json_file_cause: "You are missing the required script.json file.",
          no_script_json_file_help: "Create this file and try again.",

          configuration_syntax_error_cause: "The script.json configuration schema is not formatted properly.",
          configuration_syntax_error_help: "Fix the errors and try again.",

          configuration_missing_keys_error_cause: "The script.json configuration schema is missing required keys: "\
                                              "%{missing_keys}.",
          configuration_missing_keys_error_help: "Add the keys and try again.",

          configuration_invalid_value_error_cause: "The script.json configuration only accepts "\
                                              "one of the following types(s): %{valid_input_modes}.",
          configuration_invalid_value_error_help: "Change the type and try again.",

          configuration_schema_field_missing_keys_error_cause: "A field entry in the script.json configuration "\
                                                     "schema is missing required keys: %{missing_keys}.",
          configuration_definition_schema_field_missing_keys_error_help: "Add the keys and try again.",

          configuration_schema_field_invalid_value_error_cause: "The script.json configuration schema fields only "\
                                                     "accept one of the following type(s): %{valid_types}.",
          configuration_schema_field_invalid_value_error_help: "Change the types and try again.",

          script_not_found_cause: "Couldn't find script %s for extension point %s",

          system_call_failure_cause: "An error was returned while running {{command:%{cmd}}}.",
          system_call_failure_help: "Review the following error and try again.\n{{red:%{out}}}",

          metadata_validation_cause: "Invalid script extension metadata.",
          metadata_validation_help: "Ensure the 'shopify/scripts-toolchain-as' package is up to date.",

          metadata_schema_versions_missing: "Invalid script metadata:" \
                                            " 'schemaVersions' field is missing",
          metadata_schema_versions_single_key: "Invalid script extension metadata:" \
                                               " 'schemaVersions' can have only one extension point name.",
          metadata_schema_versions_missing_major: "Invalid script extension metadata:" \
                                                  " 'schemaVersions' is missing the 'major' field",
          metadata_schema_versions_missing_minor: "Invalid script extension metadata:" \
                                                  " 'schemaVersions' is missing the 'minor' field",

          metadata_not_found_cause: "Script version file (%s) cannot be found.",
          metadata_not_found_help: "Ensure the 'shopify/scripts-toolchain-as' package is up to date and " \
                                     "'package.json' contains a 'scripts/build' entry with a " \
                                     "'--metadata build/metadata.json' argument",
          app_not_installed_cause: "App not installed on store.",

          build_error_cause: "Something went wrong while building the script.",
          build_error_help: "Correct the errors and try again.",

          dependency_install_cause: "Something went wrong while installing the dependencies that are needed.",
          dependency_install_help: "Correct the errors and try again.",

          failed_api_request_cause: "Something went wrong while communicating with Shopify.",
          failed_api_request_help: "Try again.",

          forbidden_error_cause: "You do not have permission to do this action.",

          graphql_error_cause: "An error was returned: %s.",
          graphql_error_help: "\nReview the error and try again.",

          script_repush_cause: "A script with this UUID already exists (UUID: %s).",
          script_repush_help: "Use {{cyan:--force}} to replace the existing script.",

          shop_auth_cause: "Unable to authenticate with the store.",
          shop_auth_help: "Try again.",

          invalid_build_script: "The root package.json contains an invalid build command that " \
                                "is needed to compile your script to WebAssembly.",
          build_script_not_found: "The root package.json is missing the build command that " \
                                  "is needed to compile your script to WebAssembly.",
          # rubocop:disable Layout/LineLength
          build_script_suggestion: "\n\nFor example, your package.json needs the following command:" \
            "\nbuild: npx shopify-scripts-toolchain-as build --src src/shopify_main.ts --binary build/<script_name>.wasm --metadata build/metadata.json -- --lib node_modules --optimize --use Date=",

          web_assembly_binary_not_found: "WebAssembly binary not found.",
          web_assembly_binary_not_found_suggestion: "No WebAssembly binary found." \
            "Check that your build npm script outputs the generated binary to the root of the directory." \
            "Generated binary should match the script name: <script_name>.wasm",
        },

        create: {
          help: <<~HELP,
          {{command:%1$s create script}}: Creates a script project.
            Usage: {{command:%1$s create script}}
            Options:
              {{command:--name=NAME}} Script project name. Use any string.
              {{command:--extension-point=TYPE}} Extension point name. Allowed values: %2$s.
              {{command:--no-config-ui}} Specify this option if you don’t want Scripts to render an interface in the Shopify admin.
          HELP

          error: {
            operation_failed: "Script not created.",
          },

          change_directory_notice: "{{*}} Change directories to {{green:%s}} to run script commands",
          creating: "Creating script",
          created: "Created script",
        },

        push: {
          help: <<~HELP,
          Build the script and put it into production. If you've already pushed a script with the same extension point, use --force to replace the current script with the newest one.
            Usage: {{command:%s push}}
            Options:
              {{command:[--force]}} Forces the script to be overwritten if an instance of it already exists.
          HELP

          error: {
            operation_failed: "Couldn't push script to app (API key: %{api_key}).",
          },

          script_pushed: "{{v}} Script pushed to app (API key: %{api_key}).",
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
            select_language: "Which language do you want to use?",
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
          ensure_env: {
            organization: "Partner organization {{green:%s (%s)}}.",
            organization_select: "Which partner organization do you want to use?",
            app: "Script will be pushed to app {{green:%s}}.",
            app_select: "Which app do you want to push this script to?",
            ask_connect_to_existing_script: "The selected app has some scripts. Do you want to replace any of the "\
              "existing scripts with the current script?",
            ask_which_script_to_connect_to: "Which script do you want to replace?",
          },
        },
      },
    }.freeze
  end
end
