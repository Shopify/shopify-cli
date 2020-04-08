require 'shopify_cli'

module Node
  module Commands
    class Populate < ShopifyCli::Command
      prerequisite_task :schema

      subcommand :Product, 'products', Project.project_filepath('commands/populate/product')
      subcommand :Customer, 'customers', Project.project_filepath('commands/populate/customer')
      subcommand :DraftOrder, 'draftorders', Project.project_filepath('commands/populate/draft_order')

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Populate your Shopify development store with example products, customers, or orders.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} populate [ products | customers | draftorders ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:products [options]}}: Add dummy products to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate products}}

            {{cyan:customers [options]}}: Add dummy customers to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate customers}}

            {{cyan:draftorders [options]}}: Add dummy orders to the specified development store.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} populate draftorders}}

          {{bold:Options:}}

            {{cyan:--count [integer]}}: The number of dummy items to populate. Defaults to 5.
            {{cyan:--silent}}: Silence the populate output.
            {{cyan:--help}}: Display more options specific to each subcommand.

          {{bold:Examples:}}

            {{command:#{ShopifyCli::TOOL_NAME} populate products}}
              Populate your development store with 5 additional products.

            {{command:#{ShopifyCli::TOOL_NAME} populate customers --count 30}}
              Populate your development store with 30 additional customers.

            {{command:#{ShopifyCli::TOOL_NAME} populate draftorders}}
              Populate your development store with 5 additional orders.

            {{command:#{ShopifyCli::TOOL_NAME} populate products --help}}
              Display the list of options available to customize the
              {{command:#{ShopifyCli::TOOL_NAME} populate products}} command.
        HELP
      end
    end
  end
end
