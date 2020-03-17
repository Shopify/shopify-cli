require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Page, 'page', 'shopify-cli/commands/generate/page'
      subcommand :Billing, 'billing', 'shopify-cli/commands/generate/billing'
      subcommand :Webhook, 'webhook', 'shopify-cli/commands/generate/webhook'

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Generate code in your app project. Supports generating new pages, new billing API calls, or new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ page | billing | webhook ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:page}}: Generate a new page in your app with the specified page name.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename>}} or
                     {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename> --type=TYPE}}
              Types:
              {{cyan:empty-state}}: generate a new page with an empty state
              {{underline:https://polaris.shopify.com/components/structure/empty-state}}

              {{cyan:list}}: generate a new page with a Resource List, generally used as an index page
              {{underline:https://polaris.shopify.com/components/lists-and-tables/resource-list}}

              {{cyan:two-column}}: generate a new page with a two column card layout, generally used for details
              {{underline:https://polaris.shopify.com/components/structure/layout}}

              {{cyan:annotated}}: generate a new page with a description and card layout, generally used for settings
              {{underline:https://polaris.shopify.com/components/structure/layout}}

            {{cyan:billing}}: Generate code to enable charging for your app using Shopify’s billing API.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}

            {{cyan:webhook}}: Generate and register a new webhook that listens for the specified Shopify store event.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}

          {{bold:Examples:}}

            {{cyan:shopify generate page onboarding}}
              Generate a new page in your app with a URL route of /onboarding.

            {{cyan:shopify generate webhook}}
              Show a list of all available webhooks in your terminal.

            {{cyan:shopify generate webhook PRODUCTS_CREATE}}
              Generate and register a new webhook that will be called every time a new product is created on your store.
        HELP
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          ctx.error(response(stat.exitstatus, name))
        end
      end

      def self.response(code, name)
        case code
        when 1
          "Error generating #{name}"
        when 2
          "#{name} already exists!"
        else
          'Error'
        end
      end
    end
  end
end
