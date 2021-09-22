require "shopify_cli"

module ShopifyCLI
  module Commands
    class App < ShopifyCLI::Command
      def call(_args, _name)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCLI::Context.message("core.app.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
