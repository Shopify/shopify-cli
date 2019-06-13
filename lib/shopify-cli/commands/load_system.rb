require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadSystem < ShopifyCli::Command
      def call(_args, _name)
        ShopifyCli::Finalize.reload_shopify_from(ShopifyCli::INSTALL_DIR)
      end

      def self.help
        <<~HELP
        Reload the installed instance of shopify-cli
          Usage: {{command:#{ShopifyCli::TOOL_NAME} load-system}}
        HELP
      end
    end
  end
end
