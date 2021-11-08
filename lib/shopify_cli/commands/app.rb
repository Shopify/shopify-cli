require "shopify_cli"

module ShopifyCLI
  module Commands
    class App < ShopifyCLI::Command
      subcommand :Connect, "connect", "shopify_cli/commands/app/connect"
      subcommand :Create, "create", "shopify_cli/commands/app/create"
      subcommand :Deploy, "deploy", "shopify_cli/commands/app/deploy"
      subcommand :Open, "open", "shopify_cli/commands/app/open"
      subcommand :Serve, "serve", "shopify_cli/commands/app/serve"
      subcommand :Tunnel, "tunnel", "shopify_cli/commands/app/tunnel"

      def call(*)
        @ctx.puts(self.class.help)
      end

      class << self
        def help
          subcommands = subcommand_registry.command_names.join(" | ")
          ShopifyCLI::Context.message("core.app.help", ShopifyCLI::TOOL_NAME, subcommands)
        end

        def call_help(*)
          @ctx.puts(help)
        end
      end
    end
  end
end
