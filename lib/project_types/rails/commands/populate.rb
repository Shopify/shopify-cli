require 'shopify_cli'

module Rails
  module Commands
    class Populate < ShopifyCli::Command
      subcommand :Product, 'products', Project.project_filepath('commands/populate/product')
      subcommand :Customer, 'customers', Project.project_filepath('commands/populate/customer')
      subcommand :DraftOrder, 'draftorders', Project.project_filepath('commands/populate/draft_order')

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message('rails.populate.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('rails.populate.extended_help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
