require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::Command
      autoload :Page, 'shopify-cli/commands/generate/page'
      autoload :Billing, 'shopify-cli/commands/generate/billing'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'page'
          Page.call(@ctx, args)
        when 'billing'
          Billing.call(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Generate code.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} generate <page> or billing}}
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
