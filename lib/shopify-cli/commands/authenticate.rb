require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        project = Project.current
        dev_store = project.env.shop
        ShopifyCli::Tasks::EnsureLoopbackURL.call(@ctx)
        begin
          case command
          when 'identity'
            run_identity
          when 'shop'
            run_shop(dev_store)
          else
            @ctx.puts(self.class.help)
          end
        rescue OAuth::Error
          @ctx.puts("{{error:Failed to Authenticate}}")
          @ctx.error("Failed to Authenticate")
        end
      end

      def run_identity
        opt = CLI::UI::Prompt.confirm('Reauthenticate with Partner Dashboard?')
        if opt
          CLI::UI::Spinner.spin("Waiting to Reauthenticate with Partner Dashboard") do |spinner|
            spinner.update_title("Reauthenticated with Partner Dashboard")
            ShopifyCli::Tasks::AuthenticateIdentity.call(@ctx)
          end
        else
          raise(ShopifyCli::AbortSilent)
        end
      end

      def run_shop(dev_store)
        opt = CLI::UI::Prompt.confirm('Open default browser to authenticate with the Partner Dashboard?')
        if opt
          CLI::UI::Spinner.spin("Waiting to authenticate with #{dev_store}") do |spinner|
            spinner.update_title("Authetication with #{dev_store}")
            ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
          end
        else
          raise(ShopifyCli::AbortSilent)
        end
      end

      def self.help
        <<~HELP
          Request a new access token for Shop or App creation.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} authenticate shop || identity}}
        HELP
      end
    end
  end
end
