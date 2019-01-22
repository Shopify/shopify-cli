require 'shopify-cli'

module ShopifyCli
  module Commands
    class LoadSystem < ShopifyCli::Command
      def call(_args, _name)
        ShopifyCli::Finalize.reload_shopify_from(ShopifyCli::INSTALL_DIR)
      end

      def self.help
        "reloads installed instance of shopify-cli"
      end
    end
  end
end
