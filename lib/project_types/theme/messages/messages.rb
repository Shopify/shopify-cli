# frozen_string_literal: true
module Theme
  module Messages
    MESSAGES = {
      theme: {
        create: {
          creating_theme: "Creating theme %s",
          checking_themekit: "Verifying Theme Kit",
          failed: "Theme could not be created",
          help: <<~HELP,
            {{command:%s create theme}}: Creates a theme.
              Usage: {{command:%s create theme}}
              Options:
                {{command:--store=MYSHOPIFYDOMAIN}} Store URL. Must be an existing store.
                {{command:--password=PASSWORD}} Private app password. App must have Read and Write Theme access.
                {{command:--name=NAME}} Theme name. Any string.
          HELP
          info: {
            created: "{{green:%s}} was created for {{underline:%s}} in {{green:%s}}",
          },
        },
        forms: {
          create: {
            ask_password: "Password:",
            ask_store: "Store domain:",
            ask_title: "Title:",
            errors: "%s cannot be empty",
            private_app: <<~APP,
              To create a new theme, we need to connect with a private app. Visit {{underline:%s/admin/apps/private}} to fetch the password.
              If you create a new private app, ensure that it has Read and Write Theme access.",
            APP
          },
        },
        tasks: {
          ensure_themekit_installed: {
            downloading: "Downloading Theme Kit %s",
            errors: {
              digest_fail: "Unable to verify download digest",
              releases_fail: "Unable to fetch Theme Kit releases",
              write_fail: "Unable to download Theme Kit",
            },
            successful: "Theme Kit installed successfully",
            verifying: "Verifying download...",
          },
        },
      },
    }.freeze
  end
end
