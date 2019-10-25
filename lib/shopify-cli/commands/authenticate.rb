require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        ShopifyCli::Tasks::EnsureLoopbackURL.call(@ctx)
        CLI::UI::Spinner.spin("Requesting access token...") do |spinner|
          begin
            case command
            when 'identity'
              ShopifyCli::Tasks::AuthenticateIdentity.call(@ctx)
            else
              ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
            end
            spinner.update_title("Authetication token stored")
          rescue OAuth::Error
            @ctx.puts("{{error:Failed to Authenticate}}")
            raise(::ShopifyCli::Abort, "Failed to Authenticate")
          end
        end
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
