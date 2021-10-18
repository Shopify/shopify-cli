# frozen_string_literal: true

module PHP
  module Messages
    MESSAGES = {
      php: {
        help: <<~HELP,
          Suite of commands for developing PHP apps with Laravel. See {{command:%1$s app php <command> --help}} for usage of each command.
            Usage: {{command:%1$s app php [ %2$s ]}}
        HELP
        create: {
          help: <<~HELP,
            {{command:%s app php create}}: Creates an embedded PHP app.
              Usage: {{command:%s app php create}}
              Options:
                {{command:--name=NAME}} App name. Any string.
                {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                {{command:--shop-domain=MYSHOPIFYDOMAIN}} Development store URL. Must be an existing development store.
                {{command:--type=APPTYPE}} Whether this app is public or custom.
                {{command:--verbose}} Output verbose information when installing dependencies.
            HELP

          error: {
            php_required: <<~VERSION,
              PHP is required to create an app project. For installation instructions, visit:
                {{underline:https://www.php.net/manual/en/install.php}}
              VERSION
            php_version_failure: <<~VERSION,
              Failed to get the current PHP version. Please make sure it is installed as per the instructions at:
                {{underline:https://www.php.net/manual/en/install.php.}}
              VERSION
            php_version_too_low: "Your PHP version is too low. Please use version %s or higher.",
            composer_required: <<~COMPOSER,
              Composer is required to create an app project. Download at:
                {{underline:https://getcomposer.org/download/}}
              COMPOSER
            npm_required: "npm is required to create an app project. Download at https://www.npmjs.com/get-npm.",
            npm_version_failure: "Failed to get the current npm version. Please make sure it is installed as per " \
              "the instructions at https://www.npmjs.com/get-npm.",
            app_setup: "Failed to set up the app",
          },

          php_version: "PHP %s",
          npm_version: "npm %s",
          app_setting_up: "Setting up app…",
          app_set_up: "App is now set up",
        },
        forms: {
          create: {
            error: {
              invalid_app_name: "App name cannot contain 'Shopify'",
              invalid_app_type: "Invalid app type %s",
            },
            app_name: "App name",
            app_type: {
              select: "What type of app are you building?",
              select_public: "Public: An app built for a wide merchant audience.",
              select_custom: "Custom: An app custom built for a single client.",
              selected: "App type {{green:%s}}",
            },
          },
        },
      },
    }.freeze
  end
end
