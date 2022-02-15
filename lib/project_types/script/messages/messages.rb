# frozen_string_literal: true

module Script
  module Messages
    MESSAGES = {
      script: {
        help: <<~HELP,
          Suite of commands for developing script applications. Run {{command:%1$s script <command> --help}} for usage of each command.
            Usage: {{command:%1$s script [ %2$s ]}}
        HELP

        error: {
          deprecated_ep: "This script won't run in a store because "\
                         "it uses a deprecated Script API (%s).",
          deprecated_ep_cause: "Recreate this script using a supported Script API.",
          generic: "{{red:{{x}} Error}}",
          eacces_cause: "You don't have permission to write to this directory.",
          eacces_help: "Get permission for this directory or choose a different one.",

          enospc_cause: "You don't have enough disk space to do this action.",
          enospc_help: "Free up more space.",

          oauth_cause: "Something went wrong while authenticating your account with the Partner Dashboard.",
          oauth_help: "Wait a few minutes and try again.",

          invalid_context_cause: "Your .shopify-cli.yml is formatted incorrectly. It's missing values for "\
                                 "extension_point_type or script_name.",
          invalid_context_help: "Add these values.",

          invalid_script_name_cause: "Script name contains unsupported characters.",
          invalid_script_name_help: "Use only numbers, letters, hyphens, or underscores.",

          no_existing_apps_cause: "Your script can't be pushed to an app because your Partner account "\
                                  "doesn't have any apps.",
          no_existing_apps_help: "Create an app.",

          no_existing_orgs_cause: "Your account doesn't belong to a Partner Organization.",
          no_existing_orgs_help: "Visit https://partners.shopify.com/ to create an account.",

          project_exists_cause: "A directory with this same name already exists.",
          project_exists_help: "Choose a different name for your script.",

          invalid_extension_cause: "The name of the Script API is incorrect: %s.",
          invalid_extension_help: "Choose a supported API: %s.",

          invalid_language_cause: "The language is not supported: %s.",
          invalid_language_help: "Choose a supported language: %s.",

          missing_script_config_field_cause: "The %{filename} file is missing the required %{field} field.",
          missing_script_config_field_help: "Add the field.",

          script_config_parse_error_cause: "The %{filename} file contains incorrect %{serialization_format}.",
          script_config_parse_error_help: "Correct the errors.",

          no_script_config_file_cause: "The %{filename} file is missing.",
          no_script_config_file_help: "Create this file.",

          app_not_connected_cause: "The script is not connected to an app.",
          app_not_connected_help: "Run {{command:%{tool_name} script connect}}.",

          configuration_definition_error_cause: "In %{filename} there is a problem with the "\
                                                "configuration. %{message}",
          configuration_definition_error_help: "Fix the error.",

          configuration_definition_errors_cause: "In %{filename}, there are %{error_count} problems with "\
                                                 "the configuration:\n%{concatenated_messages}\n",
          configuration_definition_errors_help: "Correct the errors.",

          configuration_syntax_error_cause: "The %{filename} is not formatted correctly.",
          configuration_syntax_error_help: "Fix the errors.",

          configuration_missing_keys_error_cause: "The %{filename} is missing required keys: "\
                                              "%{missing_keys}.",
          configuration_missing_keys_error_help: "Add the keys.",

          configuration_invalid_value_error_cause: "The %{filename} configuration accepts "\
                                                   "one of the following types(s): %{valid_input_modes}.",
          configuration_invalid_value_error_help: "Change the value of the type.",

          configuration_schema_field_missing_keys_error_cause: "A configuration entry in the %{filename} file "\
                                                     "is missing required keys: %{missing_keys}.",
          configuration_definition_schema_field_missing_keys_error_help: "Add the keys.",

          configuration_schema_field_invalid_value_error_cause: "The configuration entries in the "\
                                                     "%{filename} file accept one of the following "\
                                                     "type(s): %{valid_types}.",
          configuration_schema_field_invalid_value_error_help: "Change the value of the type.",

          script_not_found_cause: "Can't find script %s for Script API %s",

          system_call_failure_cause: "Something went wrong while running: {{command:%{cmd}}}.",
          system_call_failure_help: "Correct the error.\n{{red:%{out}}}",

          metadata_validation_cause: "The Script API metadata is incorrect.",
          metadata_validation_help: "The 'schemaVersions.major' field contains an unsupported version.",

          metadata_schema_versions_missing: "Invalid Script metadata:" \
                                            " 'schemaVersions' field is missing",
          metadata_schema_versions_single_key: "Invalid Script API metadata:" \
                                               " 'schemaVersions' can have only one Script API name.",
          metadata_schema_versions_missing_major: "Invalid Script API metadata:" \
                                                  " 'schemaVersions' is missing the 'major' field",
          metadata_schema_versions_missing_minor: "Invalid Script API metadata:" \
                                                  " 'schemaVersions' is missing the 'minor' field",

          metadata_not_found_cause: "Can't find the script version file (%{filename}).",
          metadata_not_found_help: "Make sure your project is up-to-date and a script metadata file " \
                                   "is accessible at %{filename}.",

          build_error_cause: "Something went wrong while building the script.",
          build_error_help: "Correct the errors.",

          dependency_install_cause: "Something went wrong while installing the needed dependencies.",
          dependency_install_help: "Correct the errors.",

          failed_api_request_cause: "Something went wrong while communicating with Shopify.",
          failed_api_request_help: "Try again.",

          forbidden_error_cause: "You don't have permission to do this action.",

          graphql_error_cause: "An error was returned: %s.",
          graphql_error_help: "\nCorrect the error.",

          script_repush_cause: "Can’t push the script because a version of this script already exists on the app.",
          script_repush_help: "Use {{cyan:--force}} to replace the existing script.",

          build_script_not_found: "The root package.json is missing the build command that " \
                                  "is needed to compile your script to Wasm.",
          # rubocop:disable Layout/LineLength
          build_script_suggestion: "\n\nFor example, your package.json needs the following command:" \
            "\nbuild: npx shopify-scripts-toolchain-as build --src src/shopify_main.ts --binary build/<script_name>.wasm --metadata build/metadata.json -- --lib node_modules --optimize --use Date=",

          web_assembly_binary_not_found: "Wasm binary not found.",
          web_assembly_binary_not_found_suggestion: "Check that there is a valid Wasm binary in the root directory" \
          "Your Wasm binary should match the script name: <script_name>.wasm",

          project_config_not_found: "Internal error - Script can't be created because the project's config file is missing from the repository.",

          invalid_project_config: "Internal error - Script can't be created because the project's config file is invalid in the repository.",

          script_upload_cause: "Something went wrong and your script couldn't be pushed.",
          script_upload_help: "Try again.",

          script_too_large_cause: "The size of your Wasm binary file is too large.",
          script_too_large_help: "It must be less than %{max_size}.",

          api_library_not_found_cause: "Script can't be created because API library %{library_name} is missing from the dependencies",
          api_library_not_found_help: "This can occur because the API library was removed from your system or there is a problem with dependencies in the repository.",

          language_library_for_api_not_found_cause: "Script can’t be pushed because the %{language} library for API %{api} is missing.",
          language_library_for_api_not_found_help: "Make sure extension_point.yml contains the correct API library.",
          no_scripts_found_in_app: "The selected apps have no scripts. Please, create them first on the partners' dashboard.",
          missing_env_file_variables: "The following are missing in the .env file: %s."\
            " To add it, run {{command:%s script connect}}",
          missing_push_options: "The following are missing: %s. "\
            "To add them to a CI environment:\n\t1. Run a connect command {{command:%s script connect}}\n\t2. Navigate to the .env file at the root of your project\n\t"\
            "3. Copy the missing values, then pass them through as arguments.",
        },

        create: {
          help: <<~HELP,
            {{command:%1$s script create}}: Creates a script project.
              Usage: {{command:%1$s script create}}
              Options:
                {{command:--name=NAME}} Script project name.
                {{command:--api=TYPE}} Script API name. Supported values: %2$s.
                {{command:--language=LANGUAGE}} Programming language. Supported values: %3$s.
          HELP

          error: {
            operation_failed: "Something went wrong and the script wasn't created.",
          },

          change_directory_notice: "{{*}} Change directories to {{green:%s}} to run script commands.",
          creating: "Creating script.",
          created: "Created script.",
          preparing_project: "Preparing script project structure.",
          creating_wasm: "Creating configuration files.",
          created_wasm: "Configuration files created.",
        },

        push: {
          help: <<~HELP,
            Build the script, upload it to Shopify, and register it to an app.
              Usage: {{command:%s script push}}
              Options:
                {{command:[--force]}} Replace the existing script with this version.
                {{command:[--api-key=API_KEY]}} The API key used to register an app with the script. This can be found on the app page on Partners Dashboard. Overrides the value in the .env file, if present.
                {{command:[--api-secret=API_SECRET]}} The API secret of the app the script is registered with. Overrides the value in the .env file, if present.
                {{command:[--uuid=UUID]}} The uuid of the script. Overrides the value in the .env file, if present.
          HELP

          error: {
            operation_failed_no_uuid: "UUID is required to push in a CI environment.",
            operation_failed_with_api_key: "Couldn't push script to app (API key: %{api_key}).",
            operation_failed_no_api_key: "Couldn't push script to app.",
          },

          script_pushed: "{{v}} Script pushed to app (API key: %{api_key}).",
        },
        connect: {
          connected: "Connected! Your project is now connected to {{green:%s}}",
          help: <<~HELP,
            {{command:%s script connect}}: Connects an existing script to an app.
              Usage: {{command:%s script connect}}
          HELP
          error: {
            operation_failed: "Couldn't connect script to app.",
            missing_env_file_variables: "The following variables are missing in the .env file: %s."\
            " To connect the script to an app, enter the value into the .env file or delete the .env file, and then run {{command:%s script connect}}",
          },
        },
        javy: {
          help: <<~HELP,
            Compile the JavaScript code into Wasm.
              Usage: {{command:%s script javy}}
              Options:
                {{command:--in}} The name of the JavaScript file that will be compiled.
                {{command:--out}} The name of the file that the Wasm should be written to.
          HELP
          errors: {
            invalid_arguments: "Javy was run with invalid arguments. Run {{command: %s script javy --help}}.",
          },
        },

        project_deps: {
          none_required: "{{v}} Dependencies are up to date.",
          checking: "Checking dependencies.",
          installing: "Installing dependencies.",
          installed: "Installed missing dependencies.",
        },

        forms: {
          create: {
            select_extension_point: "Which Script API do you want to use?",
            script_name: "What do you want to name your script?",
          },
        },

        application: {
          building: "Building",
          building_script: "Building script",
          built: "Built",
          pushing: "Pushing",
          pushing_script: "Pushing script",
          pushed: "Pushed",
          ensure_env: {
            organization: "Partner organization {{green:%s (%s)}}.",
            organization_select: "Which partner organization do you want to use?",
            app: "Push script to app {{green:%s}}.",
            app_select: "Which app do you want to push this script to?",
            ask_connect_to_existing_script: "This app contains scripts. Do you want to replace an "\
              "existing script on the app with this script?",
            ask_which_script_to_connect_to: "Which script do you want to replace?",
          },
        },
      },
    }.freeze
  end
end
