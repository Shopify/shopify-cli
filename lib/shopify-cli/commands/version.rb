require 'shopify_cli'

module ShopifyCli
  module Commands
    class Version < ShopifyCli::Command
      def call(_args, _name)
        @ctx.puts(ShopifyCli::VERSION.to_s)
      end

      def self.help
        <<~HELP
          Prints version number.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} version}}
        HELP
      end
    end
  end
end
