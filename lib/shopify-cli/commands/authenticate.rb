require 'shopify_cli'

module ShopifyCli
  module Commands
    class Authenticate < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        ShopifyCli::Tasks::EnsureLoopbackURL.call(@ctx)
        begin
          case command
          when 'identity'
            run_task(ShopifyCli::Tasks::AuthenticateIdentity.call(@ctx))
          else
            opt = ask_for_auth
            opt ? run_task(ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)) : abort
          end
        rescue OAuth::Error
          @ctx.puts("{{error:Failed to Authenticate}}")
          raise(::ShopifyCli::Abort, "Failed to Authenticate")
        end
      end

      def ask_for_auth
        CLI::UI::Prompt.confirm('Open default browser to authenticate with the Partner Dashboard?')
      end

      def run_task(task_to_run)
        CLI::UI::Spinner.spin("Waiting to authenticate") do |spinner|
          spinner.update_title("Authetication token stored")
          task_to_run
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
