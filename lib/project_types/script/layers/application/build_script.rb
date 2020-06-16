# frozen_string_literal: true

module Script
  module Layers
    module Application
      class BuildScript
        class << self
          def call(ctx:, script:)
            return if CLI::UI::Frame.open(ctx.message('script.application.building')) do
              begin
                UI::StrictSpinner.spin(ctx.message('script.application.building_script')) do |spinner|
                  build(ctx, script)
                  spinner.update_title(ctx.message('script.application.built'))
                end
                true
              rescue StandardError => e
                CLI::UI::Frame.with_frame_color_override(:red) do
                  ctx.puts("\n{{red:#{e.message}}}")
                end
                false
              end
            end
            raise Infrastructure::Errors::BuildError
          end

          private

          def build(ctx, script)
            script_repo = Infrastructure::ScriptRepository.new
            task_runner = Infrastructure::TaskRunner.for(ctx, script)
            script_content = script_repo.with_temp_build_context do
              task_runner.build
            end

            Infrastructure::PushPackageRepository.new
              .create_push_package(script, script_content, task_runner.compiled_type)
          end
        end
      end
    end
  end
end
