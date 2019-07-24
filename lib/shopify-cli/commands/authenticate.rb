require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(args, _name)
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add("Requesting access token...") do |spinner|
          case args.shift
          when 'identity'
            ShopifyCli::Tasks::AuthenticateIdentity.call(@ctx)
          when 'shop'
            ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
          else
            ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
          end
          spinner.update_title("Authetication token stored")
        end
        spin_group.wait
      end

      def self.help
        <<~HELP
          Request a new access token from the Shopify Admin API.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} authenticate}}
        HELP
      end
    end
  end
end
