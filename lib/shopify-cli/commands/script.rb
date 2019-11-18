require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script < ShopifyCli::Command
      subcommand :Create, 'create', 'shopify-cli/commands/script/create'
      subcommand :Deploy, 'deploy', 'shopify-cli/commands/script/deploy'
      subcommand :Test, "test", "shopify-cli/commands/script/test"

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Development with script V2
            Usage: {{command:#{ShopifyCli::TOOL_NAME} script [ create | deploy | test ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:create}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script create <extension point> <script name>}}

            {{cyan:deploy}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script deploy <extension point> <script name>}}

            {{cyan:test}}: Creates an app based on type selected.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} script test <extension point> <script name>}}
        HELP
      end
    end
  end
end
