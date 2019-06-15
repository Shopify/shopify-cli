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
          Populate dev store with products, customers and order records.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} populate <storename>}}
        HELP
      end
    end
  end
end
