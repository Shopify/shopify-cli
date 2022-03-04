# frozen_string_literal: true

module Script
  module Layers
    module Application
      class BuildScript
        class << self
          def call(ctx:, task_runner:, script_project:, library:)
            CLI::UI::Frame.open(ctx.message("script.application.building")) do
              UI::StrictSpinner.spin(ctx.message("script.application.building_script")) do |spinner|
                task_runner.build
                spinner.update_title(ctx.message("script.application.built"))
              end
            rescue StandardError => e
              CLI::UI::Frame.with_frame_color_override(:red) do
                ctx.puts("\n{{red:#{e.message}}}")
              end
              errors = [
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
