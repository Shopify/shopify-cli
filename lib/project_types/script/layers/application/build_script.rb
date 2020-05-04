# frozen_string_literal: true

module Script
  module Layers
    module Application
      class BuildScript
        BUILDING_MSG = "Building script"
        BUILT_MSG = "Built"

        class << self
          def call(ctx:, script:)
            raise Infrastructure::Errors::BuildError unless CLI::UI::Frame.open('Building') do
              begin
                UI::StrictSpinner.spin(BUILDING_MSG) do |spinner|
                  build(script)
                  spinner.update_title(BUILT_MSG)
                end
                true
              rescue StandardError => e
                CLI::UI::Frame.with_frame_color_override(:red) do
                  ctx.puts("\n{{red:#{e.message}}}")
                end
                false
              end
            end
          end

          private

          def build(script)
            script_repo = Infrastructure::ScriptRepository.new
            script_builder = Infrastructure::ScriptBuilder.for(script)
            compiled_type = script_builder.compiled_type
            script_content, schema = script_repo.with_temp_build_context do
              script_builder.build
            end

            Infrastructure::DeployPackageRepository.new
              .create_deploy_package(script, script_content, schema, compiled_type)
          end
        end
      end
    end
  end
end
