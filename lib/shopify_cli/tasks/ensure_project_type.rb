require "shopify_cli"

module ShopifyCli
  module Tasks
    class EnsureProjectType < ShopifyCli::Task
      def call(ctx, project_type)
        return true if project_type.to_sym == ShopifyCli::Project.current_project_type
        ctx.abort(ctx.message("core.tasks.ensure_project_type.wrong_project_type", project_type))
      end
    end
  end
end
