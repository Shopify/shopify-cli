require "shopify_cli"

module Node
  class Command
    class Open < ShopifyCLI::Command::AppSubCommand
      prerequisite_task ensure_project_type: :node

      def call(*)
        project = ShopifyCLI::Project.current
        @ctx.open_url!("#{project.env.host}/auth?shop=#{project.env.shop}")
      end

      def self.help
        ShopifyCLI::Context.message("node.open.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
