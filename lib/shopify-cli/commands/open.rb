require 'shopify_cli'

module ShopifyCli
  module Commands
    class Open < ShopifyCli::ContextualCommand
      include Helpers::OS

      available_in :app

      prerequisite_task :tunnel

      def call(*)
        open_url!(@ctx, Project.current.app_type.open_url)
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
