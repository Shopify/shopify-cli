require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::ContextualCommand
      available_in :top_level

      subcommand :Project, 'project', 'shopify-cli/commands/create/project'

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Create a new app project.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:project}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}

              Options:
                {{command:--type=TYPE}}  App project type. Valid types are "node" and "rails"
                {{command:--title=TITLE}} App project title. Any string.
                {{command:--app_url=APPURL}} App project URL. Must be valid URL.
                {{command:--organization_id=ID}} App project Org ID. Must be existing org ID.
                {{command:--shop_domain=MYSHOPIFYDOMAIN }} Test store URL. Must be existing test store.

            {{cyan:dev-store}}: {{yellow: Create dev-store is not currently available.}}
        HELP
      end
    end
  end
end
