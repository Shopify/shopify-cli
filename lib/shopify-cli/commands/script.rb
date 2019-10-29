require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script < ShopifyCli::Command
      subcommand :Create, 'create', 'shopify-cli/commands/script/create'
      subcommand :Deploy, 'deploy', 'shopify-cli/commands/script/deploy'
      subcommand :GenerateFromSchema, 'generate-from-schema', 'shopify-cli/commands/script/generate_from_schema'
      subcommand :Test, "test", "shopify-cli/commands/script/test"

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Development with script V2
            Usage: {{command:#{ShopifyCli::TOOL_NAME} script [ create | deploy | generate-from-schema | test ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:create}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script create <extension point> <script name>}}

            {{cyan:deploy}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script deploy <extension point> <script name>}}

            {{cyan:generate-from-schema}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script generate-from-schema <extension point> <script name> --config}}
        HELP
      end
    end
  end
end
