require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
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
            if command == 'shop' || command.nil?
              @ctx.puts "{{*}} Remeber to add {{underline: #{OAuth::REDIRECT_HOST}:3456"\
                "to the whitelisted redirection URLs in your app setup"
            end
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
