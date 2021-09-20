require "shopify_cli"

module ShopifyCli
  module Commands
    class Populate < ShopifyCli::Command
      subcommand :Customer, "customers", "shopify_cli/commands/populate/customer"
      subcommand :DraftOrder, "draftorders", "shopify_cli/commands/populate/draft_order"
      subcommand :Product, "products", "shopify_cli/commands/populate/product"

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message("core.populate.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("core.populate.extended_help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
