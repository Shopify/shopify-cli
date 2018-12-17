require 'shopify-cli'

module ShopifyCli
  module Commands
    class Server < ShopifyCli::Command
      def call(args, _name)
        CLI::Kit::System.system('npm run dev')
      end

      def self.help
        "Run a server.\nUsage: {{command:#{ShopifyCli::TOOL_NAME} server}}"
      end
    end
  end
end
