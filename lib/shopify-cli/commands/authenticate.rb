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
          when 'shop'
            opt = CLI::UI::Prompt.confirm('Open default browser to authenticate with the Partner Dashboard?')
            opt ? run_task(ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)) : abort
          else
            @ctx.puts(self.class.help)
          end
        rescue OAuth::Error
          @ctx.puts("{{error:Failed to Authenticate}}")
          raise(::ShopifyCli::Abort, "{{x}} Failed to Authenticate")
        end
      end

      def run_task(task_to_run)
        CLI::UI::Spinner.spin("Waiting to authenticate") do |spinner|
          spinner.update_title("Authetication token stored")
          task_to_run
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
