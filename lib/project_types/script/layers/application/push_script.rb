# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, force:)
            script_project = ScriptProject.current
            task_runner = Infrastructure::TaskRunner.for(ctx, script_project.language, script_project.script_name)
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script_project: script_project)

            UI::PrintingSpinner.spin(ctx, ctx.message("script.application.pushing")) do |p_ctx, spinner|
              package = Infrastructure::PushPackageRepository.new(ctx: p_ctx).get_push_package(
                script_project: script_project,
                compiled_type: task_runner.compiled_type,
                metadata: task_runner.metadata
              )
              package.push(Infrastructure::ScriptService.new(ctx: p_ctx), script_project.api_key, force)
              spinner.update_title(p_ctx.message("script.application.pushed"))
            end
          end
        end
      end
    end
  end
end
