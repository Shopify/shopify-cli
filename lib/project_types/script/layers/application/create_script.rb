# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, script_name:, extension_point_type:, no_config_ui:)
            raise Infrastructure::Errors::ScriptProjectAlreadyExistsError, script_name if ctx.dir_exist?(script_name)

            in_new_directory_context(ctx, script_name) do
              extension_point = ExtensionPoints.get(type: extension_point_type)
              script_project_repo = Infrastructure::ScriptProjectRepository.new(ctx: ctx)
              project = script_project_repo.create(
                script_name: script_name,
                extension_point_type: extension_point_type,
                language: language,
                no_config_ui: no_config_ui
              )
              project_creator = Infrastructure::Languages::ProjectCreator
                .for(ctx, language, extension_point, script_name, project.id)
              install_dependencies(ctx, language, script_name, project_creator)
              bootstrap(ctx, project_creator)
              script_project_repo.update_script_json(title: script_name, configuration_ui: !no_config_ui)
              project
            end
          end

          private

          def install_dependencies(ctx, language, script_name, project_creator)
            task_runner = Infrastructure::Languages::TaskRunner.for(ctx, language, script_name)
            project_creator.setup_dependencies
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
          end

          def bootstrap(ctx, project_creator)
            UI::StrictSpinner.spin(ctx.message("script.create.creating")) do |spinner|
              project_creator.bootstrap
              spinner.update_title(ctx.message("script.create.created"))
            end
          end

          def in_new_directory_context(ctx, directory)
            initial_directory = ctx.root
            begin
              ctx.mkdir_p(directory)
              ctx.chdir(directory)
              yield
            rescue
              ctx.chdir(initial_directory)
              ctx.rm_r(directory)
              raise
            ensure
              ctx.chdir(initial_directory)
            end
          end
        end
      end
    end
  end
end
