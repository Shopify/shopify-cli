module ShopifyCLI
  module Commands
    class App
      class Create < ShopifyCLI::Command
        subcommand :Rails, "rails", "shopify_cli/commands/app/create/rails"
        subcommand :PHP, "php", "shopify_cli/commands/app/create/php"
        subcommand :Node, "node", "shopify_cli/commands/app/create/node"

        def call(_args, _command_name)
          @ctx.puts(self.class.help)
        end

        def self.help
          ShopifyCLI::Context.message("core.app.create.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end

        def self.call_help(*)
          output = help
          if respond_to?(:extended_help)
            output += "\n"
            output += extended_help
          end
          @ctx.puts(output)
        end
      end
    end
  end
end
