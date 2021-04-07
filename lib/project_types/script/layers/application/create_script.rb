# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, script_name:, extension_point_type:, no_config_ui:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            project = Infrastructure::ScriptProjectRepository.new(ctx: ctx).create(
              script_name: script_name,
              extension_point_type: extension_point_type,
              language: language,
              no_config_ui: no_config_ui
            )
            project_creator = Infrastructure::ProjectCreator
              .for(ctx, language, extension_point, script_name, project.id)
            install_dependencies(ctx, language, script_name, project_creator)
            bootstrap(ctx, project_creator)
            project
          end

          private

          def install_dependencies(ctx, language, script_name, project_creator)
            task_runner = Infrastructure::TaskRunner.for(ctx, language, script_name)
            project_creator.setup_dependencies
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
          end

          def bootstrap(ctx, project_creator)
            UI::StrictSpinner.spin(ctx.message("script.create.creating")) do |spinner|
              project_creator.bootstrap
              spinner.update_title(ctx.message("script.create.created"))
            end
          end
        end
      end
    end
  end
end
