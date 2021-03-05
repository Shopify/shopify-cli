require "shopify_cli"

module Rails
  module Commands
    class Open < ShopifyCli::Command
      def call(*)
        project = ShopifyCli::Project.current
        @ctx.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
      end

      def self.help
        ShopifyCli::Context.message("rails.open.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
