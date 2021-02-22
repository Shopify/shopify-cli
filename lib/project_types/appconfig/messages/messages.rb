# frozen_string_literal: true

module AppConfig
  module Messages
    MESSAGES = {
      appconfig: {
        error: {
          generic: "Error",
        },
        create: {
          help: <<~HELP,
            {{command:%s create appconfig}}: Creates a new app in your partner dashboard.
            Usage: {{command:%s create appconfig}}
            Options:
              {{command:--name=NAME}} App name. Any string.
              {{command:--organization_id=ID}} Partner organization ID. Must be an existing organization.
              {{command:--app_url=APPURL}} App URL. Must be a valid URL.
              {{command:--allowed_redirection_urls=APPREDIRECTIONURL}} App URL or comma seperated list of App URLs
            HELP

          created: "New app config created: {{green:%s}}",
          production_warning: <<~MESSAGE,
            {{yellow:! Warning: if you have connected to an {{bold:app in production}}, running {{command:serve}} may update the app URL and cause an outage.
            MESSAGE
        },

        forms: {
          create: {
            app_name: "App name",
            app_url: "App install URL",
            app_type: {
              select: "What type of app are you building?",
              select_public: "Public: An app built for a wide merchant audience.",
              select_custom: "Custom: An app custom built for a single client.",
              selected: "App type {{green:%s}}",
            },
            allowed_redirection_urls: "Allowed redirection URL(s) (seperate multiples with commas)",

            error: {
              invalid_app_type: "Invalid app type %s",
              invalid_org: "nah son %s",
              invalid_redirection_urls: "Invalid Redirection URL(s): %s",
            },
          },
        },
      },
    }.freeze
  end
end
