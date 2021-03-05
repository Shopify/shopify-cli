require "shopify_cli"

module ShopifyCli
  module Commands
    class Version < ShopifyCli::Command
      def self.help
        ShopifyCli::Context.message("core.version.help", ShopifyCli::TOOL_NAME)
      end

      def call(_args, _name)
        @ctx.puts(ShopifyCli::VERSION.to_s)
      end
    end
  end
end
