require "shopify_cli"

module ShopifyCLI
  module Tasks
    class EnsureProjectType < ShopifyCLI::Task
      def call(ctx, project_type)
        if project_type.to_sym == ShopifyCLI::Project.current_project_type || Environment.run_as_subprocess?
          return true
        end
        ctx.abort(ctx.message("core.tasks.ensure_project_type.wrong_project_type", project_type))
      end
    end
  end
end
