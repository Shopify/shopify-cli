# frozen_string_literal: true

module ShopifyCli
  module Messages
    MESSAGES = {
      core: {
        connect: {
          help: <<~HELP,
          Connect a Shopify App CLI project. Restores the ENV file.
            Usage: {{command:%s connect}}
          HELP

          production_warning: "{{yellow:! Don't use}} {{cyan:connect}} {{yellow:for production apps}}",
          connected: "{{v}} Project now connected to {{green:%s}}",
          serve: "{{*}} Run {{command:%s serve}} to start a local development server",
          organization_select: "To which organization does this project belong?",
          app_select: "To which app does this project belong?",
          no_development_stores: <<~MESSAGE,
          No development stores available.
          Visit {{underline:https://partners.shopify.com/%d/stores}} to create one
          MESSAGE
          development_store_select: "Which development store would you like to use?",
        },

        create: {
          help: <<~HELP,
          Create a new project.
            Usage: {{command:%s create [ %s ]}}
          HELP

          error: {
            invalid_app_type: "{{red:Error}}: invalid app type {{bold:%s}}",
          },

          app_type_select: "What type of project would you like to create?",
        },

        help: {
          error: {
            command_not_found: "Command %s not found.",
          },

          preamble: <<~MESSAGE,
          CLI to help build Shopify apps faster.

          Use {{command:%s help <command>}} to display detailed information about a specific command.

          {{bold:Available commands}}
          MESSAGE
        },

        load_dev: {
          help: <<~HELP,
          Load a development instance of Shopify App CLI from the given path. This command is intended for development work on the CLI itself.
            Usage: {{command:%s load-dev `/absolute/path/to/cli/instance`}}
          HELP

          error: {
            project_dir_not_found: "{{x}} %s does not exist",
          },

          reloading: "Reloading %s from %s",
        },

        load_system: {
          help: <<~HELP,
          Reload the installed instance of Shopify App CLI. This command is intended for development work on the CLI itself.
            Usage: {{command:%s load-system}}
          HELP

          reloading: "Reloading %s from %s",
        },

        logout: {
          help: <<~HELP,
          Log out of a currently authenticated Organization and Shop, or clear invalid credentials
            Usage: {{command:%s logout}}
          HELP

          success: "Logged out of Organization and Shop",
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
          command: "{{x}} %s",
          ngrok_available: "{{v}} ngrok, %s",
          ngrok_not_available: "{{x}} ngrok NOT available",
          project: {
            header: "{{bold:In a {{cyan:%s}} project directory}}",
            command_with_path: "{{v}} %s, %s, version %s",
            command: "{{x}} %s",
            env_header: "{{bold:Project environment}}",
            env_not_set: "not set",
            env: "%-18s = %s",
            no_env: "{{x}} .env file not present",
          },
          environment_header: "{{bold:Environment}}",
          env: "%-17s = %s",
        },

        update: {
          help: <<~HELP,
          Update Shopify App CLI.
            Usage: {{command:%s update}}
          HELP
        },
      },
    }.freeze
  end
end