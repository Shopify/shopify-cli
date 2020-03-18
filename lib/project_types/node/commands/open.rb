require 'shopify_cli'

module Node
  module Commands
    class Open < ShopifyCli::Command
      def call(*)
        @ctx.open_url!(Project.current.app_type.open_url)
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
