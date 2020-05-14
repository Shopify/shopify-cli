require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadSystem < ShopifyCli::Command
      hidden_command

      def call(_args, _name)
        @ctx.done(@ctx.message('core.load_system.reloading', TOOL_FULL_NAME, ShopifyCli::INSTALL_DIR))
        ShopifyCli::Core::Finalize.reload_shopify_from(ShopifyCli::INSTALL_DIR)
      end

      def self.help
        ShopifyCli::Context.message('core.load_system.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
