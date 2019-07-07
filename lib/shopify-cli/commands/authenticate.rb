require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(*)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add("Requesting access token...") do |spinner|
          ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
          spinner.update_title("Authetication token stored")
        end
        spin_group.wait
      end

      def self.help
        <<~HELP
          Request a new access token from the Shopify admin API.
            Usage:{{command:#{ShopifyCli::TOOL_NAME} authenticate}}
        HELP
      end
    end
  end
end
