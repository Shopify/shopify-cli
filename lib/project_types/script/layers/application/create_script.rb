# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, sparse_checkout_branch:, script_name:, extension_point_type:)
            script_project_repo = Infrastructure::ScriptProjectRepository.new(
              ctx: ctx,
              directory: script_name,
              initial_directory: ctx.root
            )

            in_new_directory_context(script_project_repo) do
              extension_point = ExtensionPoints.get(type: extension_point_type)
              project = script_project_repo.create(
                script_name: script_name,
                extension_point_type: extension_point_type,
                language: language
              )

              # remove the need to pass the whole extension-point object to the infra layer
              sparse_checkout_repo = extension_point.libraries.for(language).repo
              type = extension_point.dasherize_type
              domain = extension_point.domain

              project_creator = Infrastructure::Languages::ProjectCreator.for(
                ctx: ctx,
                language: language,
                type: type,
                project_name: script_name,
                path_to_project: project.id,
                sparse_checkout_repo: sparse_checkout_repo,
                sparse_checkout_branch: sparse_checkout_branch,
                sparse_checkout_set_path: "#{domain}/#{language}/#{type}/default"
              )

              install_dependencies(ctx, language, script_name, project_creator)
              script_project_repo.update_script_config(title: script_name)
              project
            end
          end

          private

          def install_dependencies(ctx, language, script_name, project_creator)
            task_runner = Infrastructure::Languages::TaskRunner.for(ctx, language)
            CLI::UI::Frame.open(ctx.message(
              "core.git.pulling_from_to",
              project_creator.sparse_checkout_repo,
              script_name,
            )) do
              UI::StrictSpinner.spin(ctx.message(
                "core.git.pulling",
                project_creator.sparse_checkout_repo,
                script_name,
              )) do |spinner|
                project_creator.setup_dependencies
                spinner.update_title(ctx.message("core.git.pulled", script_name))
              end
            end
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
          end

          def in_new_directory_context(script_project_repo)
            script_project_repo.create_project_directory
            yield
          rescue Infrastructure::Errors::ScriptProjectAlreadyExistsError
            raise
          rescue
            script_project_repo.delete_project_directory
            raise
          ensure
            script_project_repo.change_to_initial_directory
          end
        end
      end
    end
  end
end
