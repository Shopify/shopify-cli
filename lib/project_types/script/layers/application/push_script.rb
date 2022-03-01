# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, force:, project:)
            script_project_repo = Infrastructure::ScriptProjectRepository.new(ctx: ctx)
            script_project = script_project_repo.get
            script_project.env = project.env
            task_runner = Infrastructure::Languages::TaskRunner
              .for(ctx, script_project.language)

            extension_point = ExtensionPoints.get(type: script_project.extension_point_type)

            library = extension_point.libraries.for(script_project.language)

            raise Infrastructure::Errors::LanguageLibraryForAPINotFoundError.new(
              language: script_project.language,
              api: script_project.extension_point_type
            ) if library.nil? && (script_project.language != "wasm")

            library_name = library&.package
            library_data = {
              language: script_project.language,
              version: task_runner.library_version(library_name),
            } if library_name

            ProjectDependencies.install(ctx: ctx, task_runner: task_runner)
            BuildScript.call(ctx: ctx, task_runner: task_runner, script_project: script_project, library: library_data)

            metadata_file_location = task_runner.metadata_file_location
            metadata = Infrastructure::MetadataRepository.new(ctx: ctx).get_metadata(metadata_file_location)

            CLI::UI::Frame.open(ctx.message("script.application.pushing")) do
              UI::PrintingSpinner.spin(ctx, ctx.message("script.application.pushing_script")) do |p_ctx, spinner|
                package = Infrastructure::PushPackageRepository.new(ctx: p_ctx).get_push_package(
                  script_project: script_project,
                  metadata: metadata,
                  library: library_data,
                )
                script_service = Infrastructure::ServiceLocator.script_service(
                  ctx: p_ctx,
                  api_key: script_project.api_key
                )
                module_upload_url = Infrastructure::ScriptUploader.new(script_service).upload(package.script_content)
                uuid = script_service.set_app_script(
                  uuid: package.uuid,
                  extension_point_type: package.extension_point_type,
                  title: package.title,
                  description: package.description,
                  force: force,
                  metadata: package.metadata,
                  script_config: package.script_config,
                  module_upload_url: module_upload_url,
                  library: package.library,
                  input_query: script_project.input_query,
                )
                if ShopifyCLI::Environment.interactive?
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
end
