# frozen_string_literal: true

module Script
  module Layers
    module Application
      class BuildScript
        class << self
          def call(ctx:, task_runner:, script:)
            CLI::UI::Frame.open(ctx.message('script.application.building')) do
              begin
                UI::StrictSpinner.spin(ctx.message('script.application.building_script')) do |spinner|
                  build(ctx, task_runner, script)
                  spinner.update_title(ctx.message('script.application.built'))
                end
              rescue StandardError => e
                CLI::UI::Frame.with_frame_color_override(:red) do
                  ctx.puts("\n{{red:#{e.message}}}")
                end
                errors = [
                  Infrastructure::Errors::InvalidBuildScriptError,
                  Infrastructure::Errors::BuildScriptNotFoundError,
                  Infrastructure::Errors::WebAssemblyBinaryNotFoundError,
                ]

                raise Infrastructure::Errors::BuildError unless errors.any? { |err| e.is_a?(err) }
                raise
              end
            end
          end

          private

          def build(ctx, task_runner, script)
            script_repo = Infrastructure::ScriptRepository.new(ctx: ctx)
            script_content = script_repo.with_temp_build_context do
              task_runner.build
            end
            Infrastructure::PushPackageRepository.new(ctx: ctx)
              .create_push_package(script, script_content, task_runner.compiled_type)
          end
        end
      end
    end
  end
end
