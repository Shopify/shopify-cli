require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::Command
      autoload :Page, 'shopify-cli/commands/generate/page'
      autoload :Billing, 'shopify-cli/commands/generate/billing'
      autoload :Webhook, 'shopify-cli/commands/generate/webhook'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'page'
          Page.call(@ctx, args)
        when 'billing'
          Billing.call(@ctx, args)
        when 'webhook'
          Webhook.call(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Generate code in your app project. Supports generating new pages, new billing API calls, or new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ page | billing | webhook ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          ------------
          Subcommands:

          {{cyan:page}}: Generate a new page in your app with the specified name. New files are generated inside the project’s “/pages” directory.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename>}}

          {{cyan:billing}}: Generate a new call to Shopify’s billing API by adding the necessary code to the project’s server.js file.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}

          {{cyan:webhook}}: Generate and register a new webhook that listens for the specified Shopify store event.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}
        HELP
      end
    end
  end
end
