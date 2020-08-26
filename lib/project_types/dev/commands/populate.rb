require 'shopify_cli'

module Dev
  module Commands
    class Populate < ShopifyCli::Command
      subcommand :Customer, 'customers', Project.project_filepath('commands/populate/customer')
      subcommand :DraftOrder, 'draftorders', Project.project_filepath('commands/populate/draft_order')
      subcommand :Product, 'products', Project.project_filepath('commands/populate/product')

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message('dev.populate.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('dev.populate.extended_help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
