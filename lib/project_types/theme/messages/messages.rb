# frozen_string_literal: true

module Theme
  module Messages
    MESSAGES = {
      theme: {
        help: <<~HELP,
          Suite of commands for developing Shopify themes. See {{command:%1$s theme <command> --help}} for usage of each command.
            Usage: {{command:%1$s theme [ %2$s ]}}
        HELP
        ensure_user_error: "You are not authorized to edit themes on %s.",
        unauthorized_error: <<~EOD,
          You can't use Shopify CLI with development stores if you only have Partner staff member access. If you want to use Shopify CLI to work on a development store, then you should be the store owner or create a staff account on the store.

          If you're the store owner, then you need to log in to the store directly using the store URL at least once (for example, using %s/admin) before you log in using Shopify CLI. Logging in to the Shopify admin directly connects the development store with your Shopify login.
        EOD
        ensure_user_try_this: <<~ENSURE_USER,
          Check if your user is activated, has permission to edit themes at the store, and try to re-login.
        ENSURE_USER
        stable_flag_suggestion: "If the current command isn't working as expected," \
          " we suggest re-running the command with the {{command: --stable}} flag",
        current_directory_is_not_theme_directory: "It doesn’t seem like you’re running this command" \
          " in a theme directory.",
        confirm_current_directory: "Are you sure you want to proceed?",
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
          done_with_errors: "{{warning:Your theme was published with errors and is now live at %s.}}",
          not_found: "Theme #%s does not exist",
          no_themes_error: "You don't have any theme to be published.",
          no_themes_resolution: "Try to create an unpublished theme with {{command:theme push -u -t <theme_name>}}.",
          select: "Select theme to push to %s",
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
                {{command:-t, --theme=NAME_OR_ID}} Theme ID or name of the remote theme.
                {{command:-l, --live}}             Push to your remote live theme, and update your live store.
                {{command:-d, --development}}      Push to your remote development theme, and create it if needed.
                {{command:-u, --unpublished}}      Create a new unpublished theme and push to it.
                {{command:-n, --nodelete}}         Runs the push command without deleting remote files from Shopify.
                {{command:-j, --json}}             Output JSON instead of a UI.
                {{command:-a, --allow-live}}       Allow push to a live theme.
                {{command:-p, --publish}}          Publish as the live theme after uploading.
                {{command:-o, --only}}             Upload only the specified files (Multiple flags allowed).
                {{command:-x, --ignore}}           Skip uploading the specified files (Multiple flags allowed).

              Run without options to select theme from a list.
          HELP
          info: {
            pushing: "Pushing theme files to %s (#%s) on %s",
          },
          push: "Pushing theme files to Shopify",
          select: "Select theme to push to %s",
          live: "Are you sure you want to push to your live theme?",
          theme: "\n  Theme: {{blue:%s #%s}} {{green:[live]}}",
          deprecated_themeid: <<~WARN,
            {{warning:The {{command:-i, --themeid}} flag is deprecated. Use {{command:-t, --theme}} instead.}}
          WARN
          theme_not_found: "Theme \"%s\" doesn't exist",
          done: <<~DONE,
            {{green:Your theme was pushed successfully}}

              {{info:View your theme:}}
              {{underline:%s}}

              {{info:Customize this theme in the Theme Editor:}}
              {{underline:%s}}
          DONE
          done_with_errors: <<~WARN,
            {{yellow:Your theme was pushed with errors.}}

              {{info:View your theme:}}
              {{underline:%s}}

              {{info:Customize this theme in the Theme Editor:}}
              {{underline:%s}}
          WARN
          name: "Theme name",
          with_errors: "Theme pushed with errors.",
        },
        serve: {
          theme_not_found: "Theme \"%s\" doesn't exist",
          help: <<~HELP,
            Uploads the current theme as a development theme to the connected store, then prints theme editor and preview URLs to your terminal. While running, changes will push to the store in real time.

            Usage: {{command:%s theme serve [ ROOT ]}}

            Options:
              {{command:-t, --theme=NAME_OR_ID}}  Theme ID or name of the remote theme.
              {{command:-o, --only}}              Hot reload only files that match the specified pattern.
              {{command:-x, --ignore}}            Skip hot reloading any files that match the specified pattern.
              {{command:-e, --theme-editor-sync}} Synchronize Theme Editor updates in the local theme files.
              {{command:--port=PORT}}             Local port to serve theme preview from.
              {{command:--poll}}                  Force polling to detect file changes.
              {{command:--host=HOST}}             Set which network interface the web server listens on. The default value is 127.0.0.1.
              {{command:--live-reload=MODE}}      The live reload mode switches the server behavior when a file is modified:
                                      - {{command:hot-reload}} Hot reloads local changes to CSS and sections (default)
                                      - {{command:full-page}}  Always refreshes the entire page
                                      - {{command:off}}        Deactivate live reload
          HELP
          reload_mode_is_not_valid: "The live reload mode `%s` is not valid.",
          try_a_valid_reload_mode: "Try a valid live reload mode: %s.",
          viewing_theme: "Viewing theme…",
          syncing_theme: "Syncing theme #%s on %s",
          open_fail: "Couldn't open the theme",
          stop_signal: "Stop signal: \"%s\"",
          stopping: "Stopping…",
          auth: {
            error_message: <<~ERROR_MESSAGE,
              It looks like you are using credentials that do not work with {{command:%s theme serve}}.
            ERROR_MESSAGE
            help_message: <<~HELP_MESSAGE,
              Run {{command:%s logout}} and {{command:%s login --password "" --store STORE}} to authenticate again.
            HELP_MESSAGE
          },
          operation: {
            status: {
              error: "ERROR",
              synced: "Synced",
              fixed: "Fixed",
            },
          },
          syncer: {
            forms: {
              apply_to_all: {
                title: "Would you like to apply this to all the other %s files?",
                yes: "Yes",
                no: "No",
              },
              update_strategy: {
                title_context: <<~TITLE,

                  The local file {{command:%s}} is different from the remote version in the development theme.
                TITLE
                title_question: "What would you like to do?",
                keep_remote: "Keep the remote version",
                keep_local: "Keep the local version",
                union_merge: "Merge files (it may break the local file)",
                exit: "Exit",
              },
              update_remote_deleted_strategy: {
                title_context: <<~TITLE,

                  The local file {{command:%s}} doesn’t exist in the remote version of the development theme.
                TITLE
                title_question: "What would you like to do?",
                keep_remote: "Keep the remote version (and remove it locally)",
                keep_local: "Keep the local version (and restore it remotely)",
                union_merge: "Merge files (it may break the local file)",
                exit: "Exit",
              },
              delete_strategy: {
                title_context: <<~TITLE,

                  The local file {{command:%s}} has been recently removed, but it's present on your remote development theme.
                TITLE
                title_question: "What would you like to do?",
                delete: "Delete permanently",
                restore: "Restore with the remote version",
                exit: "Exit",
              },
            },
            warnings: {
              unsupported_script: "unsupported script",
              unsupported_script_text: <<~UNSUPPORTED_SCRIPT,

                {{underline:Unsupported external checkout script}}

                You have a code snippet on your storefront that violates
                Shopify's Terms of Service. This script removes Shopify's
                ability to protect your store against fraudulent orders,
                could steal customer data and may cause customers to be
                charged the wrong amount.

                %s
                By proceeding, you're acknowledging that you understand the
                risks and will not hold Shopify liable for any problems that
                occur due to the use of an external checkout, including:

                - Discounts
                - Shipping rules
                - Multi-currency rules
                - Variant selection
                - Orders and fulfillment workflows
                - Shopify Fraud Protection
                - Payment settings
                - Cart

                You also acknowledge that you will not be able to reliably
                get support for those features from Shopify because you are
                violating Shopify's terms of service and that your account
                may become suspended as a result.
              UNSUPPORTED_SCRIPT
              line_and_column: <<~LINE_AND_COLUMN,
                - Line: %s Column: %s
              LINE_AND_COLUMN
            },
          },
          error: {
            invalid_subdirectory: <<~MESSAGE,
              The presence of %s in the directory structure isn't supported.

              Move any files to a parent folder, then delete unsupported subdirectories.

              • Required directory structure: https://shopify.dev/themes/architecture#directory-structure-and-component-types
            MESSAGE
          },
          serving: <<~SERVING,

            Serving %s

          SERVING
          download_changes: ", and use 'theme pull' to get the changes",
          customize_or_preview: <<~CUSTOMIZE_OR_PREVIEW,

            Customize this theme in the Theme Editor%s:
            {{green:%s}}

            Share this theme preview:
            {{green:%s}}

            (Use Ctrl-C to stop)
          CUSTOMIZE_OR_PREVIEW
          ensure_user: <<~ENSURE_USER,
            You are not authorized to edit themes on %s.
            Check if your user is activated, has permission to edit themes at the store, and try to re-login.
          ENSURE_USER
          address_already_in_use: "The address \"%s\" is already in use.",
          try_port_option: "Use the --port=PORT option to serve the theme in a different port.",
          binding_error: "Couldn't bind to localhost." \
            " To serve your theme, set a different address with {{command:%s theme serve --host=<address>}}",
        },
        check: {
          help: <<~HELP,
            Check your theme for errors, suggestions, and best practices.
            Usage: {{command:%s check}}
          HELP
          error: "Theme check failed with error:\n%s",
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
          select: "Select theme to delete from %s",
          done: "%s theme(s) deleted",
          no_themes_error: "You don't have any theme to be deleted.",
          no_themes_resolution: "Try to create an unpublished theme with {{command:theme push -u -t <theme_name>}}.",
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
            prereq_command_required: "zip or 7zip is required for packaging a theme. Please install "\
              "zip or 7zip using the appropriate package manager for your system.",
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
              {{command:-t, --theme=NAME_OR_ID}} Theme ID or name of the remote theme.
              {{command:-l, --live}}             Pull theme files from your remote live theme.
              {{command:-d, --development}}      Pull theme files from your remote development theme.
              {{command:-n, --nodelete}}         Runs the pull command without deleting local files.
              {{command:-o, --only}}             Download only the specified files (Multiple flags allowed).
              {{command:-x, --ignore}}           Skip downloading the specified files (Multiple flags allowed).

            Run without options to select theme from a list.
          HELP
          select: "Select a theme to pull from %s",
          pulling: "Pulling theme files from %s (#%s) on %s",
          done: "Theme pulled successfully.",
          done_with_errors: "{{warning:Your theme was pulled with errors.}}",
          deprecated_themeid: <<~WARN,
            {{warning:The {{command:-i, --themeid}} flag is deprecated. Use {{command:-t, --theme}} instead.}}
          WARN
          theme_not_found: "Theme \"%s\" doesn't exist",
        },
        open: {
          select: "Select a theme to open in %s",
          theme_not_found: "Theme \"%s\" doesn't exist",
          details: <<~DETAILS,
            {{*}} {{bold:%s}}

            Preview your theme:
            {{green:%s}}

            Customize your theme in the Theme Editor:
            {{green:%s}}

          DETAILS
          help: <<~HELP,
            {{command:%s theme open}}: Opens the preview of your remote theme.

            Usage: {{command:%s theme open}}

            Options:
              {{command:-t, --theme=NAME_OR_ID}} Theme ID or name of your theme.
              {{command:-l, --live}}             Open your live theme.
              {{command:-d, --development}}      Open your development theme.
              {{command:-e, --editor}}           Open the theme editor for the specified theme in the browser.
          HELP
        },
        list: {
          title: "{{*}} List of {{bold:%s}} themes:",
          help: <<~HELP,
            {{command:%s theme list}}: Lists your remote themes.

            Usage: {{command:%s theme list}}
          HELP
        },
        share: {
          help: <<~HELP,
            {{command:%s theme share}}: Creates a shareable, unpublished, and new theme on your theme library with a randomized name.
                                 Works like an alias to {{command:theme push -u -t=RANDOMIZED_NAME}}.

            Usage: {{command:%s theme share [ ROOT ]}}
          HELP
          done: <<~DONE,
            {{green:The {{bold:%s}} theme was pushed successfully}}

              {{info:Share your theme preview:}}
              {{underline:%s}}

          DONE
          upload: "Pushing theme files to %s (#%s) on %s",
        },
      },
    }.freeze

    def self.all
      # In order to support theme development inside CLI3, we spawn CLI2 as a
      # subprocess. Whenever an error happens, we want to show the updated
      # version of the commands for the user to try.
      if ShopifyCLI::Environment.run_as_subprocess?
        ShopifyCLI::Utilities.deep_merge(MESSAGES, {
          theme: {
            serve: {
              auth: {
                error_message: <<~ERROR_MESSAGE,
                  It looks like you are using credentials that do not work with {{command:%s theme dev}}.
                ERROR_MESSAGE
                help_message: <<~HELP_MESSAGE,
                  Run {{command:%s auth logout}} and {{command:%s theme dev --store STORE}} to authenticate again.
                HELP_MESSAGE
              },
              binding_error: "Couldn't bind to localhost." \
                " To serve your theme, set a different address with {{command:%s theme dev --host=<address>}}",
            },
          },
        })
      else
        MESSAGES
      end
    end
  end
end
