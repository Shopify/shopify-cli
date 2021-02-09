# frozen_string_literal: true

module Script
  module Layers
    module Application
      class BuildScript
        class << self
          def call(ctx:, task_runner:, script_name:, extension_point_type:)
            CLI::UI::Frame.open(ctx.message('script.application.building')) do
              begin
                UI::StrictSpinner.spin(ctx.message('script.application.building_script')) do |spinner|
                  Infrastructure::PushPackageRepository.new(ctx: ctx).create_push_package(
                    extension_point_type,
                    script_name,
                    task_runner.build,
                    task_runner.compiled_type,
                    task_runner.metadata
                  )
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
        end
      end
    end
  end
end
