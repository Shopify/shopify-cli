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

          project_exists_cause: "Directory with the same name as the script already exists.",
          project_exists_help: "Use different script name and try again.",

          invalid_extension_cause: "Invalid extension point %s",
          invalid_extension_help: "Allowed values: discount and unit_limit_per_order.",

          script_not_found_cause: "Couldn't find script %s for extension point %s",

          dependency_install_cause: "Something went wrong while installing the dependencies that are needed.",
          dependency_install_help: "See https://help.shopify.com",

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
          created: "{{v}} Script created: {{green:%{script_id}}}",
          select_extension_point: "Which extension point do you want to use?",
          name: "Script Name",
          spinner_creating: "Creating script",
          spinner_created: "Created script",
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
      },
    }.freeze
  end
end
