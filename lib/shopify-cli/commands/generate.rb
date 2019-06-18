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
          Generate code.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [page|billing|webhook]}}
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

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          raise(ShopifyCli::Abort, response(stat.exitstatus, name))
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
