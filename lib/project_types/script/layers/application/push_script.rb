# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, language:, extension_point_type:, script_name:, source_file:, api_key:, force:)
            script = Infrastructure::ScriptRepository.new(ctx: ctx).get_script(
              language,
              extension_point_type,
              script_name
            )
            task_runner = Infrastructure::TaskRunner.for(ctx, language, script_name, source_file)
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script: script)
            check_if_safe_to_push(ctx, task_runner)
            push_script(ctx, task_runner, script, api_key, force)
          end

          private

          def check_if_safe_to_push(ctx, task_runner)
            UI::PrintingSpinner.spin(ctx, ctx.message('script.application.checking')) do |p_ctx, spinner|
              task_runner.check_if_safe_to_push!
              spinner.update_title(p_ctx.message('script.application.checked'))
            end
          end

          def push_script(ctx, task_runner, script, api_key, force)
            UI::PrintingSpinner.spin(ctx, ctx.message('script.application.pushing')) do |p_ctx, spinner|
              Infrastructure::PushPackageRepository.new(ctx: p_ctx)
                .get_push_package(script, task_runner.compiled_type)
                .push(Infrastructure::ScriptService.new(ctx: p_ctx), api_key, force)
              spinner.update_title(p_ctx.message('script.application.pushed'))
            end
          end
        end
      end
    end
  end
end
