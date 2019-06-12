require 'shopify_cli'

module ShopifyCli
  module Commands
    class Update < ShopifyCli::Command
      def self.help
        "Update shopify-cli."
      end

      def call(_args, _name)
        ShopifyCli::Update.check_now(restart_command_after_update: false, ctx: @ctx)
      end
    end
  end
end
