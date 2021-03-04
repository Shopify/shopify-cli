# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, script_name:, extension_point_type:, description:, no_config_ui:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            project = setup_project(
              ctx: ctx,
              language: language,
              script_name: script_name,
              extension_point: extension_point,
              description: description,
              no_config_ui: no_config_ui
            )
            project_creator = Infrastructure::ProjectCreator
              .for(ctx, language, extension_point, script_name, project.directory)
            install_dependencies(ctx, language, script_name, project_creator)
            bootstrap(ctx, project_creator)
            project
          end

          private

          DEFAULT_CONFIG_UI_FILENAME = "ui-config.yml"
          DEFAULT_CONFIG = {
            "version" => 1,
            "type" => "single",
            "fields" => [],
          }

          def setup_project(ctx:, language:, script_name:, extension_point:, description:, no_config_ui:)
            ScriptProject.create(ctx, script_name)

            identifiers = {
              extension_point_type: extension_point.type,
              script_name: script_name,
              language: language,
              description: description,
            }

            unless no_config_ui
              require "yaml" # takes 20ms, so deferred as late as possible.
              identifiers.merge!(config_ui_file: DEFAULT_CONFIG_UI_FILENAME)
              Infrastructure::ConfigUiRepository
                .new(ctx: ctx)
                .create_config_ui(DEFAULT_CONFIG_UI_FILENAME, YAML.dump(DEFAULT_CONFIG))
            end

            ScriptProject.write(
              ctx,
              project_type: :script,
              organization_id: nil, # TODO: can you provide this at creation
              **identifiers
            )
            ScriptProject.current
          end

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
