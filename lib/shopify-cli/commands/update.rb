require 'shopify_cli'

module ShopifyCli
  module Commands
    class Update < ShopifyCli::Command
      def self.help
        <<~HELP
          Update Shopify App CLI.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} update}}
        HELP
      end

      def call(_args, _name)
        ShopifyCli::Core::Update.check_now(restart_command_after_update: false, ctx: @ctx)
      end
    end
  end
end
