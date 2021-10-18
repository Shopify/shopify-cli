# frozen_string_literal: true

module Node
  module Messages
    MESSAGES = {
      node: {
        help: <<~HELP,
          Suite of commands for developing Node.js apps. See {{command:%1$s app node <command> --help}} for usage of each command.
            Usage: {{command:%1$s app node [ %2$s ]}}
        HELP

        error: {
          generic: "Error",
        },

        create: {
          help: <<~HELP,
            {{command:%s app node create}}: Creates an embedded nodejs app.
              Usage: {{command:%s app node create}}
              Options:
                {{command:--name=NAME}} App name. Any string.
                {{command:--organization-id=ID}} Partner organization ID. Must be an existing organization.
                {{command:--store=MYSHOPIFYDOMAIN }} Development store URL. Must be an existing development store.
          HELP
          error: {
            node_required: "node is required to create an app project. Download at https://nodejs.org/en/download.",
            node_version_failure: "Failed to get the current node version. Please make sure it is installed as " \
              "per the instructions at https://nodejs.org/en.",
            npm_required: "npm is required to create an app project. Download at https://www.npmjs.com/get-npm.",
            npm_version_failure: "Failed to get the current npm version. Please make sure it is installed as per " \
              "the instructions at https://www.npmjs.com/get-npm.",
          },
          node_version: "node %s",
          npm_version: "npm %s",
        },
        generate: {
          help: <<~HELP,
            {{red:The {{command:generate}} command is no longer supported.}}
              You can complete any tasks previously supported by {{command:generate}} with these guides:
              {{green:page}}
                Create a page with Polaris design components: {{green:https://shopify.dev/tutorials/build-a-shopify-app-with-node-and-react/build-your-user-interface-with-polaris}}

              {{green:webhook}}
                Register and process webhooks: {{green:https://github.com/Shopify/shopify-node-api/blob/main/docs/usage/webhooks.md}}

              {{green:billing}}
                Create and manage app billing models: {{green:https://shopify.dev/tutorials/bill-for-your-app-using-graphql-admin-api}}
          HELP
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
