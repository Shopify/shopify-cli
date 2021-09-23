require "shopify_cli"

module ShopifyCLI
  module Commands
    class Version < ShopifyCLI::Command
      def self.help
        ShopifyCLI::Context.message("core.version.help", ShopifyCLI::TOOL_NAME)
      end

      def call(_args, _name)
        @ctx.puts(ShopifyCLI::VERSION.to_s)
      end
    end
  end
end
