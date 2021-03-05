require "shopify_cli"

module Node
  module Commands
    class Open < ShopifyCli::Command
      def call(*)
        project = ShopifyCli::Project.current
        @ctx.open_url!("#{project.env.host}/auth?shop=#{project.env.shop}")
      end

      def self.help
        ShopifyCli::Context.message("node.open.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
