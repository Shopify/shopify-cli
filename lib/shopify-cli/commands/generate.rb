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
          Subcommands:

          * page: Generates code for a page or section of pages in your app. Usage:

              {{command:#{ShopifyCli::TOOL_NAME} generate page [name]}}

          * billing: Generates code for calling the Shopify Billing API and
            accepting usage charges for your app. Usage:

              {{command:#{ShopifyCli::TOOL_NAME} generate billing}}

          * webhook: Generates code for registering and responding to a webhook
            from Shopify. Usage:

              {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}
        HELP
      end
    end
  end
end
