# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, script_name:, extension_point_type:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            project = setup_project(ctx, script_name, extension_point)
            project_creator = Infrastructure::ProjectCreator
              .for(ctx, language, extension_point, script_name, project.directory)
            install_dependencies(ctx, language, script_name, project_creator)
            bootstrap(ctx, project_creator)
            project
          end

          private

          def setup_project(ctx, script_name, extension_point)
            ScriptProject.create(ctx, script_name)
            ScriptProject.write(
              ctx,
              project_type: :script,
              organization_id: nil, # TODO: can you provide this at creation
              extension_point_type: extension_point.type,
              script_name: script_name
            )
            ScriptProject.current
          end

          def install_dependencies(ctx, language, script_name, project_creator)
            task_runner = Infrastructure::TaskRunner.for(ctx, language, script_name)
            project_creator.setup_dependencies
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
          end

          def bootstrap(ctx, project_creator)
            UI::StrictSpinner.spin(ctx.message('script.create.creating')) do |spinner|
              project_creator.bootstrap
              spinner.update_title(ctx.message('script.create.created'))
            end
          end
        end
      end
    end
  end
end
