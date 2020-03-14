require 'shopify_cli'

module Node
  module Commands
    class Open < ShopifyCli::Command
      include ShopifyCli::Helpers::OS

      prerequisite_task :tunnel

      def call(*)
        project = ShopifyCli::Project.current
        open_url!(@ctx, "#{project.env.host}/auth?shop=#{project.env.shop}")
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
