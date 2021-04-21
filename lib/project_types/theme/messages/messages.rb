# frozen_string_literal: true
module Theme
  module Messages
    MESSAGES = {
      theme: {
        help: <<~HELP,
          Suite of commands for developing Shopify themes. See {{command:%1$s theme <command> --help}} for usage of each command.
            Usage: {{command:%1$s theme [ %2$s ]}}
        HELP

        connect: {
          duplicate: "Duplicate directory, theme files weren't connected",
          help: <<~HELP,
            {{command:%s theme connect}}: Connects an existing theme in your store to Shopify CLI. Creates a config file.
              Usage: {{command:%s theme connect}}
          HELP
          inside_project: "You are inside an existing theme, theme files weren't connected",
          connect: "Downloading theme files...",
          connected: "Successfully connected. Config file created at {{green:%s}}",
        },
        create: {
          creating_theme: "Creating theme %s",
          duplicate_theme: "Duplicate theme",
          failed: "Couldn't create the theme, %s",
          help: <<~HELP,
            {{command:%s theme create}}: Creates a theme.
              Usage: {{command:%s theme create}}
              Options:
                {{command:--store=MYSHOPIFYDOMAIN}} Store URL. Must be an existing store with private apps enabled.
                {{command:--password=PASSWORD}} Private app password. App must have Read and Write Theme access.
                {{command:--name=NAME}} Theme name. Any string.
          HELP
          info: {
            created: "{{green:%s}} was created for {{underline:%s}} in {{green:%s}}",
            dir_created: "Created directories",
          },
        },
        deploy: {
          abort: "Theme wasn't deployed",
          confirmation: "This will change your live theme. Do you wish to proceed?",
          deploying: "Deploying theme",
          error: "Theme couldn't be deployed",
          help: <<~HELP,
            {{command:%s theme deploy}}: Uploads your local theme files to Shopify, then sets your theme as the live theme.
              Usage: {{command:%s theme deploy}}
          HELP
          info: {
            deployed: "Theme was updated and set as the live theme",
            pushed: "All theme files were updated",
          },
          push_fail: "Theme files couldn't be updated",
        },
        forms: {
          ask_password: "Password:",
          ask_store: "Store domain:",
          create: {
            ask_title: "Title:",
            private_app: <<~APP,
              To create a new theme, Shopify CLI needs to connect with a private app installed on your store. Visit {{underline:%s/admin/apps/private}} to create a new API key and password, or retrieve an existing password.
              If you create a new private app, ensure that it has Read and Write Theme access.
            APP
          },
          connect: {
            private_app: <<~APP,
              To fetch your existing themes, Shopify CLI needs to connect with your store. Visit {{underline:%s/admin/apps/private}} to create a new API key and password, or retrieve an existing password.
              If you create a new private app, ensure that it has Read and Write Theme access.
            APP
          },
          errors: "%s can't be blank",
        },
        generate: {
          env: {
            ask_password: "Password",
            ask_password_default: "Password (defaults to {{green:%s}})",
            ask_store: "Store",
            ask_store_default: "Store (defaults to {{green:%s}})",
            ask_theme: "Select theme",
            help: <<~HELP,
              Create or update configuration file in the current directory.
                Usage: {{command:%s theme generate env}}
                Options:
                  {{command:--store=MYSHOPIFYDOMAIN}} Store URL. Must be an existing store with private apps enabled.
                  {{command:--password=PASSWORD}} Private app password. App must have Read and Write Theme access.
                  {{command:--themeid=THEMEID}} Theme ID. Must be an existing theme on your store.
            HELP
            no_themes: "Please create a new theme using %s create theme",
          },
          help: <<~HELP,
            Generate code in your Theme. Currently supports generating new envs.
              Usage: {{command:%s theme generate [ env ]}}
          HELP
        },
        push: {
          remove_abort: "Theme files weren't deleted",
          remove_confirm: "This will delete the local and remote copies of the theme files. Do you wish to proceed?",
          error: {
            push_error: "Theme files couldn't be pushed to Shopify",
            remove_error: "Theme files couldn't be removed from Shopify",
          },
          help: <<~HELP,
            {{command:%s theme push}}: Uploads your local theme files to Shopify, overwriting the remote versions.

              Usage: {{command:%s theme push [ path ]}}

              Options:
                {{command:-i, --themeid=THEMEID}} Theme ID. Must be an existing theme on your store.
                {{command:-d, --development}}     Push to your own remote development theme, creating it if needed.
                {{command:    --nodelete}}        Runs the push command without deleting remote files from Shopify.

              Run without options to select theme form a list.
          HELP
          info: {
            pushing: "Pushing theme files to %s (#%s) on %s",
          },
          push: "Pushing theme files to Shopify",
          select: "Select theme to push to",
          theme_not_found: "Theme #%s does not exist",
        },
        serve: {
          help: <<~HELP,
            Sync your current changes, then view the active store in your default browser. Any theme edits will continue to update in real time. Also prints the active store's URL in your terminal.
            Usage: {{command:%s theme serve}}
          HELP
          serve: "Viewing theme...",
          open_fail: "Couldn't open the theme",
        },
        check: {
          help: <<~HELP,
            Check your theme for errors, suggestions and best practices.
            Usage: {{command:%s check}}
          HELP
        },
        tasks: {
          ensure_themekit_installed: {
            auto_update: "Would you like to enable auto-updating?",
            downloading: "Downloading Theme Kit %s",
            errors: {
              digest_fail: "Unable to verify download",
              releases_fail: "Unable to fetch Theme Kit's list of releases",
              update_fail: "Unable to update Theme Kit",
              write_fail: "Unable to download Theme Kit",
            },
            installing_themekit: "Installing Theme Kit",
            successful: "Theme Kit installed successfully",
            updating_themekit: "Updating Theme Kit",
            verifying: "Verifying download...",
          },
        },
        themekit: {
          query_themes: {
            bad_password: "Bad password",
            not_connect: "Couldn't connect to given shop",
          },
        },
      },
    }.freeze
  end
end
