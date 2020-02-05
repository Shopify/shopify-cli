require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::ContextualCommand
      subcommand :App, 'app', 'shopify-cli/commands/create/app'
      subcommand :Script, 'script', 'shopify-cli/commands/create/script'
      available_in_contexts 'create', [:top_level]

      def call(*)
        @ctx.puts(self.class.help)
      end
    end
  end
end
