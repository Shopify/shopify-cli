require "shopify_cli"

module Node
  class Command
    class Open < ShopifyCli::SubCommand
      prerequisite_task ensure_project_type: :node

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
