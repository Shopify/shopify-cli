# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, force:)
            script_project = Infrastructure::ScriptProjectRepository.new(ctx: ctx).get
            task_runner = Infrastructure::TaskRunner.for(ctx, script_project.language, script_project.script_name)
            config_ui = Infrastructure::ConfigUiRepository
              .new(ctx: ctx)
              .get_config_ui(script_project.config_ui&.filename)

            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script_project: script_project, config_ui: config_ui)

            UI::PrintingSpinner.spin(ctx, ctx.message("script.application.pushing")) do |p_ctx, spinner|
              package = Infrastructure::PushPackageRepository.new(ctx: p_ctx).get_push_package(
                script_project: script_project,
                compiled_type: task_runner.compiled_type,
                metadata: task_runner.metadata,
                config_ui: config_ui,
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
