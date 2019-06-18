require 'shopify_cli'
require 'optparse'

module ShopifyCli
  module Commands
    class Populate < ShopifyCli::Command
      autoload :Resource, 'shopify-cli/commands/populate/resource'
      autoload :Product, 'shopify-cli/commands/populate/product'

      DEFAULT_COUNT = 5

      def call(args, _name)
        count = DEFAULT_COUNT
        OptionParser.new do |parser|
          # TODO: find a better way to do flags
          parser.on('-c COUNT', '--count=COUNT', 'Number of resources to generate') do |c|
            count = c.to_i
          end
        end.parse(args)
        subcommand = args.shift
        case subcommand
        when 'products'
          Product.new(ctx: @ctx).populate(count)
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
