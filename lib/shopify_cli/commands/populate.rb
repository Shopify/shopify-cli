require "shopify_cli"

module ShopifyCLI
  module Commands
    class Populate < ShopifyCLI::Command
      subcommand :Customer, "customers", "shopify_cli/commands/populate/customer"
      subcommand :DraftOrder, "draftorders", "shopify_cli/commands/populate/draft_order"
      subcommand :Product, "products", "shopify_cli/commands/populate/product"

      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCLI::Context.message("core.populate.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("core.populate.extended_help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
