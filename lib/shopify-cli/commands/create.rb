require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
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
              Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}} or any combination of
                     {{command:#{ShopifyCli::TOOL_NAME} create project <appname> --type=TYPE}}
                     {{command:#{ShopifyCli::TOOL_NAME} create project <appname> --title=TITLE}}
                     {{command:#{ShopifyCli::TOOL_NAME} create project <appname> --app_url=APPURL}}
                     {{command:#{ShopifyCli::TOOL_NAME} create project <appname> --organization_id=ID}}
                     {{command:#{ShopifyCli::TOOL_NAME} create project <appname> --shop_domain=MYSHOPIFYDOMAIN}}

            {{cyan:dev-store}}: {{yellow: Create dev-store is not currently available.}}
        HELP
      end
    end
  end
end
