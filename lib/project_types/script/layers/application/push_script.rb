# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, force:, project:)
            is_interactive = ctx.tty?
            script_project_repo = Infrastructure::ScriptProjectRepository.new(ctx: ctx)
            script_project = script_project_repo.get
            puts "SCRIPT PROJECT #{script_project.inspect}"
            script_project.env = project.env
            puts "SCRIPT PROJECT NEW #{script_project.inspect}"
            task_runner = Infrastructure::Languages::TaskRunner
              .for(ctx, script_project.language, script_project.script_name)

            extension_point = ExtensionPoints.get(type: script_project.extension_point_type)
            library_name = extension_point.libraries.for(script_project.language)&.package
            raise Infrastructure::Errors::LanguageLibraryForAPINotFoundError.new(
              language: script_project.language,
              api: script_project.extension_point_type
            ) unless library_name

            library = {
              language: script_project.language,
              version: task_runner.library_version(library_name),
            }

            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script_project: script_project, library: library)

            UI::PrintingSpinner.spin(ctx, ctx.message("script.application.pushing")) do |p_ctx, spinner|
              package = Infrastructure::PushPackageRepository.new(ctx: p_ctx).get_push_package(
                script_project: script_project,
                compiled_type: task_runner.compiled_type,
                metadata: task_runner.metadata,
                library: library,
              )
              script_service = Infrastructure::ServiceLocator.script_service(
                ctx: p_ctx,
                api_key: script_project.api_key
              )
              module_upload_url = Infrastructure::ScriptUploader.new(script_service).upload(package.script_content)
              uuid = script_service.set_app_script(
                uuid: package.uuid,
                extension_point_type: package.extension_point_type,
                force: force,
                metadata: package.metadata,
                script_config: package.script_config,
                module_upload_url: module_upload_url,
                library: package.library,
              )
              if is_interactive
                script_project_repo.update_env(uuid: uuid)
              end
              spinner.update_title(p_ctx.message("script.application.pushed"))
            end
          end
        end
      end
    end
  end
end
