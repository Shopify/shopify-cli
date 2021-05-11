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
          remove_confirm: "This will delete the local and remote copies of the theme files, which can't be undone. Do you want to continue?",
          error: {
            push_error: "Theme files couldn't be pushed to Shopify",
            remove_error: "Theme files couldn't be removed from Shopify",
          },
          help: <<~HELP,
            {{command:%s theme push}}: Uploads your local theme files to the connected store, overwriting the remote version if specified. Push will fail if the theme uses the GitHub integration.

              Usage: {{command:%s theme push [ ROOT ]}}

              Options:
                {{command:-i, --themeid=THEMEID}} Theme ID. Must be an existing theme on your store.
                {{command:-d, --development}}     Push to your remote development theme, and create it if needed.
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
            Uploads the current theme as a development theme to the store that you're connected to, and opens it in your default browser. While running, changes will push to the store in real time. Also prints the connected store URL to your terminal.
            Usage: {{command:%s theme serve}}
          HELP
          serve: "Viewing theme...",
          open_fail: "Couldn't open the theme",
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
              {{command:-f, --force}}           Do not ask for confirmation.

            Run without options to select the theme to delete from a list.
          HELP
          select: "Select theme to delete",
          done: "%s theme(s) deleted",
          not_found: "{{x}} Theme #%s does not exist",
          live: "{{x}} Theme #%s is your live theme. You can't delete it.",
          confirm: "Are you sure you want to delete %s on %s?",
        },
      },
    }.freeze
  end
end
