require 'shopify_cli'

module Rails
  module Commands
    class Open < ShopifyCli::Command
      def call(*)
        project = ShopifyCli::Project.current
        @ctx.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
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
