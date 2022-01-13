# frozen_string_literal: true
module Theme
  module Messages
    MESSAGES = {
      theme: {
        help: <<~HELP,
          Suite of commands for developing Shopify themes. See {{command:%1$s theme <command> --help}} for usage of each command.
            Usage: {{command:%1$s theme [ %2$s ]}}
        HELP

        init: {
          help: <<~HELP,
            {{command:%s theme init}}: Clones a Git repository to use as a starting point for building a new theme.

              Usage: {{command:%s theme init [ NAME ]}}

              Options:
                {{command:-u, --clone-url=URL}} The Git URL to clone from. Defaults to Shopify's example theme, Dawn: https://github.com/Shopify/dawn.git
          HELP
          ask_name: "Theme name",
        },
        publish: {
          confirmation: "This will change your live theme. Do you want to continue?",
          deploying: "Deploying theme",
          error: "Theme couldn't be deployed",
          help: <<~HELP,
            {{command:%s theme publish}}: Set a remote theme as the live theme.
              Usage: {{command:%s theme publish [ THEME_ID ]}}

              Options:
                {{command:-f, --force}}         Skip confirmation.

              Run without arguments to select theme from a list.
          HELP
          done: "Your theme is now live at %s",
          not_found: "Theme #%s does not exist",
          select: "Select theme to push to",
          confirm: "Are you sure you want to make %s the new live theme on %s?",
        },
        forms: {
          ask_password: "Password:",
          ask_store: "Store domain:",
          errors: "%s can't be blank",
        },
        push: {
          remove_abort: "Theme files weren't deleted",
          remove_confirm:
            "This will delete the local and remote copies of the theme files, which " \
            "can't be undone. Do you want to continue?",
          error: {
            push_error: "Theme files couldn't be pushed to Shopify",
            remove_error: "Theme files couldn't be removed from Shopify",
          },
          help: <<~HELP,
            {{command:%s theme push}}: Uploads your local theme files to the connected store, overwriting the remote version if specified.

              Usage: {{command:%s theme push [ ROOT ]}}

              Options:
                {{command:-i, --themeid=THEMEID}} Theme ID. Must be an existing theme on your store.
                {{command:-l, --live}}            Push to your remote live theme, and update your live store.
                {{command:-d, --development}}     Push to your remote development theme, and create it if needed.
                {{command:-u, --unpublished}}     Create a new unpublished theme and push to it.
                {{command:-n, --nodelete}}        Runs the push command without deleting remote files from Shopify.
                {{command:-j, --json}}            Output JSON instead of a UI.
                {{command:-a, --allow-live}}      Allow push to a live theme.
                {{command:-p, --publish}}         Publish as the live theme after uploading.

              Run without options to select theme from a list.
          HELP
          info: {
            pushing: "Pushing theme files to %s (#%s) on %s",
          },
          push: "Pushing theme files to Shopify",
          select: "Select theme to push to",
          live: "Are you sure you want to push to your live theme?",
          theme: "\n  Theme: {{blue:%s #%s}} {{green:[live]}}",
          theme_not_found: "Theme #%s doesn't exist",
          done: <<~DONE,
            {{green:Your theme was pushed successfully}}

              {{info:View your theme:}}
              {{underline:%s}}

              {{info:Customize this theme in the Online Store Editor:}}
              {{underline:%s}}
          DONE
          name: "Theme name",
        },
        serve: {
          help: <<~HELP,
            Uploads the current theme as a development theme to the connected store, then prints theme editor and preview URLs to your terminal. While running, changes will push to the store in real time.

            Usage: {{command:%s theme serve}}

            Options:
              {{command:--port=PORT}} Local port to serve theme preview from
              {{command:--poll}}      Force polling to detect file changes
              {{command:--host=HOST}} Set which network interface the web server listens on. The default value is 127.0.0.1.
          HELP
          viewing_theme: "Viewing theme…",
          syncing_theme: "Syncing theme #%s on %s",
          open_fail: "Couldn't open the theme",
          operation: {
            status: {
              error: "ERROR",
              synced: "Synced",
              fixed: "Fixed",
            },
          },
          error: {
            address_binding_error: "Couldn't bind to localhost."\
              " To serve your theme, set a different address with {{command:%s theme serve --host=<address>}}",
          },
          serving: <<~SERVING,

            Serving %s

          SERVING
          customize_or_preview: <<~CUSTOMIZE_OR_PREVIEW,

            Customize this theme in the Online Store Editor:
            {{green:%s}}

            Share this theme preview:
            {{green:%s}}

            (Use Ctrl-C to stop)
          CUSTOMIZE_OR_PREVIEW
          ensure_user: <<~ENSURE_USER,
            You are not authorized to edit themes on %s.
            Make sure you are a user of that store, and allowed to edit themes.
          ENSURE_USER
          already_in_use_error: "Error",
          address_already_in_use: "The address \"%s\" is already in use.",
          try_this: "Try this",
          try_port_option: "Use the --port=PORT option to serve the theme in a different port.",
        },
        check: {
          help: <<~HELP,
            Check your theme for errors, suggestions, and best practices.
            Usage: {{command:%s check}}
          HELP
        },
        delete: {
          help: <<~HELP,
            {{command:%s theme delete}}: Delete remote themes from the connected store. This command can't be undone.

            Usage: {{command:%s theme delete [ THEME_ID [ ... ] ]}}

            Options:
              {{command:-d, --development}}     Delete your development theme.
              {{command:-a, --show-all}}        Include others development themes in theme list.
              {{command:-f, --force}}           Skip confirmation.

            Run without options to select the theme to delete from a list.
          HELP
          select: "Select theme to delete",
          done: "%s theme(s) deleted",
          not_found: "{{x}} Theme #%s does not exist",
          live: "{{x}} Theme #%s is your live theme. You can't delete it.",
          confirm: "Are you sure you want to delete %s on %s?",
        },
        package: {
          help: <<~HELP,
            {{command:%s theme package}}: Package your theme into a .zip file, ready to upload to the Online Store.

            Usage: {{command:%s theme package [ ROOT ]}}
          HELP
          error: {
            prereq_command_required: "%1$s is required for packaging a theme. Please install %1$s "\
              "using the appropriate package manager for your system.",
            missing_config: "Provide a config/settings_schema.json to package your theme",
            missing_theme_name: "Provide a theme_info.theme_name configuration in config/settings_schema.json",
          },
          done: "Theme packaged in %s",
        },
        language_server: {
          help: <<~HELP,
            {{command:%1$s theme language-server}}: Start a Language Server Protocol server.

            Usage: {{command:%1$s theme language-server}}
          HELP
        },
        pull: {
          help: <<~HELP,
            {{command:%s theme pull}}: Downloads your remote theme files locally.

            Usage: {{command:%s theme pull [ ROOT ]}}

            Options:
              {{command:-i, --themeid=THEMEID}} The Theme ID. Must be an existing theme on your store.
              {{command:-l, --live}}            Pull theme files from your remote live theme.
              {{command:-d, --development}}     Pull theme files from your remote development theme.
              {{command:-n, --nodelete}}        Runs the pull command without deleting local files.

            Run without options to select theme from a list.
          HELP
          select: "Select a theme to pull from",
          pulling: "Pulling theme files from %s (#%s) on %s",
          done: "Theme pulled successfully",
          not_found: "{{x}} Theme #%s doesn't exist",
        },
      },
    }.freeze
  end
end
