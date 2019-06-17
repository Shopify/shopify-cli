require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate < ShopifyCli::Command
      prerequisite_task :schema

      autoload :Resource, 'shopify-cli/commands/populate/resource'
      autoload :Product, 'shopify-cli/commands/populate/product'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'products'
          Product.new(ctx: @ctx, args: args).populate
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Populate your Shopify development store with example products, customers, or orders.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} populate <storename> [ products | customers | orders ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:products [options]}}: Add dummy products to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate <storename> products}}

            {{cyan:orders [options]}}: Add dummy orders to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}

            {{cyan:customers [options]}}: Add dummy customers to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}

          {{bold:Options:}}

            {{cyan:--count [integer]}}: The number of dummy items to populate. Defaults to 10.

          {{bold:Examples:}}

            {{cyan:shopify populate <storename> products}}
              Populate your development store with 10 additional products.

            {{cyan:shopify populate <storename> customers --count 30}}
              Populate your development store with 30 additional customers.

            {{cyan:shopify populate orders}}
              Populate your development store with 10 additional orders.
        HELP
      end
    end
  end
end
