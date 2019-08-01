require 'shopify_cli'

module ShopifyCli
  module Commands
    class Open < ShopifyCli::Command
      prerequisite_task :tunnel

      def call(*)
        @ctx.system('open', "\"#{Project.current.app_type.open_url}\"")
      end

      def self.help
        <<~HELP
          Open your local development app in the default browser.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} open}}
        HELP
      end
    end
  end
end
