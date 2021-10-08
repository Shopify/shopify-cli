require "shopify_cli"

module Rails
  class Command
    class Open < ShopifyCLI::SubCommand
      prerequisite_task ensure_project_type: :rails

      def call(*)
        project = ShopifyCLI::Project.current
        @ctx.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
      end

      def self.help
        ShopifyCLI::Context.message("rails.open.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
