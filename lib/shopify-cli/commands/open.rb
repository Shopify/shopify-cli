require 'shopify_cli'

module ShopifyCli
  module Commands
    class Open < ShopifyCli::Command
      include Helpers::OS

      prerequisite_task :tunnel

      def call(*)
        @ctx.system(*open_cmd, "\"#{Project.current.app_type.open_url}\"")
      end

      def self.help
        <<~HELP
          Open your local development app in the default browser.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} open}}
        HELP
      end

      private

      def open_cmd
        if mac?
          %w(open)
        else
          %w(python -m webserver)
        end
      end
    end
  end
end
