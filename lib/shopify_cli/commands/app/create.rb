module ShopifyCLI
  module Commands
    class App
      class Create < ShopifyCLI::Command
        subcommand :Rails, "rails", "shopify_cli/commands/app/create/rails"
        subcommand :PHP, "php", "shopify_cli/commands/app/create/php"
        subcommand :Node, "node", "shopify_cli/commands/app/create/node"

        def call(*)
          @ctx.puts(self.class.help)
        end

        def self.help
          ShopifyCLI::Context.message("core.app.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
