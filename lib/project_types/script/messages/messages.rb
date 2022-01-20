# frozen_string_literal: true

module Script
  module Messages
    MESSAGES = {
      script: {
        help: <<~HELP,
          Suite of commands for developing script applications. See {{command:%1$s script <command> --help}} for usage of each command.
            Usage: {{command:%1$s script [ %2$s ]}}
        HELP

        error: {
          deprecated_ep: "This project uses a Script API (%s) that has been deprecated. "\
                         "This Script won't work in production.",
          deprecated_ep_cause: "Try using a different Script API.",
          generic: "{{red:{{x}} Error}}",
          eacces_cause: "You don't have permission to write to this directory.",
          eacces_help: "Try again and choose a different directory.",

          enospc_cause: "You don't have enough disk space to do this action.",
          enospc_help: "Free up some space and try again.",

          oauth_cause: "Something went wrong while authenticating your account with the Partner Dashboard.",
          oauth_help: "Try again.",

          invalid_context_cause: "Your .shopify-cli.yml file is not correct. Values are missing for "\
                                 "extension_point_type or script_name.",
          invalid_context_help: "Add these values and try again.",

          invalid_script_name_cause: "Invalid script name.",
          invalid_script_name_help: "Replace or remove unsupported characters. Valid characters "\
                                    "are numbers, letters, hyphens, or underscores.",

          no_existing_apps_cause: "You don't have any apps in your Partner Dashboard.",
          no_existing_apps_help: "Create an app with {{command:shopify [node|rails] create}}" \
                                 " or visit https://partners.shopify.com/.",

          no_existing_orgs_cause: "You don't have any partner organizations.",
          no_existing_orgs_help: "Visit https://partners.shopify.com/ to create a partners account.",

          project_exists_cause: "A directory with this same name already exists.",
          project_exists_help: "Try again and enter a different name for the script.",

          invalid_extension_cause: "Invalid Script API %s.",
          invalid_extension_help: "Allowed values: %s.",

          invalid_language_cause: "Invalid language %s.",
          invalid_language_help: "Allowed values: %s.",

          missing_script_config_field_cause: "The %{filename} file is missing the required %{field} field.",
          missing_script_config_field_help: "Add the field and try again.",

          script_config_parse_error_cause: "The %{filename} file contains invalid %{serialization_format}.",
          script_config_parse_error_help: "Fix the errors and try again.",

          no_script_config_file_cause: "The %{filename} file is missing.",
          no_script_config_file_help: "Create this file and try again.",

          app_not_connected_cause: "Script is not connected to an app.",
          app_not_connected_help: "Run shopify connect or enter fields for api-key and api-secret.",

          configuration_definition_error_cause: "In the %{filename} file, there was a problem with the "\
                                                "configuration. %{message}",
          configuration_definition_error_help: "Fix the error and try again.",

          configuration_syntax_error_cause: "The %{filename} is not formatted properly.",
          configuration_syntax_error_help: "Fix the errors and try again.",

          configuration_missing_keys_error_cause: "The %{filename} file is missing required keys: "\
                                              "%{missing_keys}.",
          configuration_missing_keys_error_help: "Add the keys and try again.",

          configuration_invalid_value_error_cause: "The %{filename} configuration only accepts "\
                                                   "one of the following types(s): %{valid_input_modes}.",
          configuration_invalid_value_error_help: "Change the type and try again.",

          configuration_schema_field_missing_keys_error_cause: "A configuration entry in the %{filename} file "\
                                                     "is missing required keys: %{missing_keys}.",
          configuration_definition_schema_field_missing_keys_error_help: "Add the keys and try again.",

          configuration_schema_field_invalid_value_error_cause: "The configuration entries in the "\
                                                     "%{filename} file only accept one of the following "\
                                                     "type(s): %{valid_types}.",
          configuration_schema_field_invalid_value_error_help: "Change the types and try again.",

          script_not_found_cause: "Couldn't find a script %s for the Script API %s",

          system_call_failure_cause: "An error was returned while running {{command:%{cmd}}}.",
          system_call_failure_help: "Review the following error and try again.\n{{red:%{out}}}",

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

          metadata_not_found_cause: "Script version file (%s) cannot be found.",
          metadata_not_found_help: "Ensure the 'shopify/scripts-toolchain-as' package is up to date and " \
                                     "'package.json' contains a 'scripts/build' entry with a " \
                                     "'--metadata build/metadata.json' argument",

          build_error_cause: "Something went wrong while building the script.",
          build_error_help: "Correct the errors and try again.",

          dependency_install_cause: "Something went wrong while installing the needed dependencies.",
          dependency_install_help: "Correct the errors and try again.",

          failed_api_request_cause: "Something went wrong while communicating with Shopify.",
          failed_api_request_help: "Try again.",

          forbidden_error_cause: "You do not have permission to do this action.",

          graphql_error_cause: "An error was returned: %s.",
          graphql_error_help: "\nReview the error and try again.",

          script_repush_cause: "A version of this script already exists on the app.",
          script_repush_help: "Use {{cyan:--force}} to replace the existing script.",

          build_script_not_found: "The root package.json is missing the build command that " \
                                  "is needed to compile your script to WebAssembly.",
          # rubocop:disable Layout/LineLength
          build_script_suggestion: "\n\nFor example, your package.json needs the following command:" \
            "\nbuild: npx shopify-scripts-toolchain-as build --src src/shopify_main.ts --binary build/<script_name>.wasm --metadata build/metadata.json -- --lib node_modules --optimize --use Date=",

          web_assembly_binary_not_found: "WebAssembly binary not found.",
          web_assembly_binary_not_found_suggestion: "No WebAssembly binary found." \
            "Check that your build npm script outputs the generated binary to the root of the directory." \
            "Generated binary should match the script name: <script_name>.wasm",

          project_config_not_found: "Internal error - Script can't be created because the project's config file is missing from the repository.",

          invalid_project_config: "Internal error - Script can't be created because the project's config file is invalid in the repository.",

          script_upload_cause: "Fail to upload script.",
          script_upload_help: "Try again.",

          api_library_not_found_cause: "Script can't be created because API library %{library_name} is missing from the dependencies",
          api_library_not_found_help: "This error can occur because the API library was removed from your system or there is a problem with dependencies in the repository.",

          language_library_for_api_not_found_cause: "Script can’t be pushed because the %{language} library for API %{api} is missing.",
          language_library_for_api_not_found_help: "Make sure extension_point.yml contains the correct API library.",
          no_scripts_found_in_app: "The selected apps have no scripts. Please, create them first on the partners' dashboard.",
          missing_env_file_variables: "The following variables are missing in the .env file: %s."\
            " It might happen when the script hasn't been previously connected to an app."\
            " To connect the script to an app, run {{command:%s script connect}}",
          missing_push_options: "The following options are required: %s."\
            " You can obtain them from the .env file generated after connecting the script to an app.",
        },

        create: {
          help: <<~HELP,
            {{command:%1$s script create}}: Creates a script project.
              Usage: {{command:%1$s script create}}
              Options:
                {{command:--name=NAME}} Script project name. Use any string.
                {{command:--api=TYPE}} Script API name. Allowed values: %2$s.
                {{command:--language=LANGUAGE}} Programming language. Allowed values: %3$s.
          HELP

          error: {
            operation_failed: "Script not created.",
          },

          change_directory_notice: "{{*}} Change directories to {{green:%s}} to run script commands",
          creating: "Creating script",
          created: "Created script",
          preparing_project: "Preparing script project structure",
          creating_wasm: "Creating configuration files",
          created_wasm: "Configuration files created",
        },

        push: {
          help: <<~HELP,
            Build the script, upload it to Shopify, and register it to an app.  If you've already pushed the script to this app, then use --force to replace the existing version on the app.
              Usage: {{command:%s script push}}
              Options:
                {{command:[--force]}} Replaces the existing script on the app with this version.
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
            " To connect the script to an app, either enter the value into the .env file or delete the .env file, then run {{command:%s script connect}}",
          },
        },
        javy: {
          help: <<~HELP,
            Compile the JavaScript code into WebAssembly.
              Usage: {{command:%s script javy}}
              Options:
                {{command:--in}} The name of the JavaScript file that will be compiled.
                {{command:--out}} The name of the file that the WebAssembly should be written to.
          HELP
          errors: {
            invalid_arguments: "Javy was run with invalid arguments. Run {{command: %s script javy --help}} for more information.",
          },
        },

        project_deps: {
          none_required: "{{v}} None required",
          checking: "Checking dependencies",
          installing: "Dependencies installing",
          installed: "Missing dependencies installed",
        },

        forms: {
          create: {
            select_extension_point: "Which Script API do you want to use?",
            select_language: "Which language do you want to use?",
            script_name: "Script name",
          },
        },

        application: {
          building: "Building",
          building_script: "Building script",
          built: "Built",
          pushing: "Pushing",
          pushed: "Pushed",
          ensure_env: {
            organization: "Partner organization {{green:%s (%s)}}.",
            organization_select: "Which partner organization do you want to use?",
            app: "Script will be pushed to app {{green:%s}}.",
            app_select: "Which app do you want to push this script to?",
            ask_connect_to_existing_script: "The selected app has some scripts. Do you want to replace any of the "\
              "existing scripts on the app with this script?",
            ask_which_script_to_connect_to: "Which script do you want to replace?",
          },
        },
      },
    }.freeze
  end
end
