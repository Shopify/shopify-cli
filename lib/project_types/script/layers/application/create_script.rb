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
                language: language
              )

              # to be overwritten with a CLI argument - for now we'll just overwrite it here during dev
              branch = "add-package-json"

              # remove the need to pass the whole extension-point object to the infra layer
              repo = extension_point.sdks.for(language).repo
              type = extension_point.dasherize_type
              domain = extension_point.domain

              sparse_checkout_set_path = "packages/#{domain}/samples/#{type}"
              if domain.nil?
                sparse_checkout_set_path = "packages/default/extension-point-as-#{type}/assembly/sample"
              end
              
              project_creator_input = {
                ctx: ctx,
                language: language,
                domain: domain,
                type: type,
                repo: repo,
                script_name: script_name,
                path_to_project: project.id,
                branch: branch,
                sparse_checkout_set_path: sparse_checkout_set_path,
              }

              project_creator = Infrastructure::Languages::ProjectCreator.for(project_creator_input)

              install_dependencies(ctx, language, script_name, project_creator)
              script_project_repo.update_or_create_script_json(title: script_name, configuration_ui: !no_config_ui)
              project
            end
          end

          private

          def install_dependencies(ctx, language, script_name, project_creator)
            task_runner = Infrastructure::Languages::TaskRunner.for(ctx, language, script_name)
            project_creator.setup_dependencies
            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
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
