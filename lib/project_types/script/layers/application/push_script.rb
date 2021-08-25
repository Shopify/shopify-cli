# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, force:)
            script_project_repo = Infrastructure::ScriptProjectRepository.new(ctx: ctx)
            script_project = script_project_repo.get
            task_runner = Infrastructure::Languages::TaskRunner
              .for(ctx, script_project.language, script_project.script_name)

            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script_project: script_project)

            UI::PrintingSpinner.spin(ctx, ctx.message("script.application.pushing")) do |p_ctx, spinner|
              package = Infrastructure::PushPackageRepository.new(ctx: p_ctx).get_push_package(
                script_project: script_project,
                compiled_type: task_runner.compiled_type,
                metadata: task_runner.metadata,
              )
              uuid = package.push(Infrastructure::ScriptService.new(ctx: p_ctx, api_key: script_project.api_key), script_project.api_key, force)
              script_project_repo.update_env(uuid: uuid)
              spinner.update_title(p_ctx.message("script.application.pushed"))
            end
          end
        end
      end
    end
  end
end
