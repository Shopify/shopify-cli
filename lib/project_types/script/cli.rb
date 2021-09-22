# frozen_string_literal: true

module Script
  class Project < ShopifyCLI::ProjectType
    hidden_feature(feature_set: :script_project)

    require Project.project_filepath("messages/messages")
    register_messages(Script::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command < ShopifyCLI::ProjectCommands
    hidden_feature(feature_set: :script_project)
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Push, "push", Project.project_filepath("commands/push")
  end
  ShopifyCLI::Commands.register("Script::Command", "script")

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
    autoload :ScriptForm, Project.project_filepath("forms/script_form")
  end

  module Tasks
    autoload :EnsureEnv, Project.project_filepath("tasks/ensure_env")
  end

  module Layers
    module Application
      autoload :BuildScript, Project.project_filepath("layers/application/build_script")
      autoload :CreateScript, Project.project_filepath("layers/application/create_script")
      autoload :PushScript, Project.project_filepath("layers/application/push_script")
      autoload :ExtensionPoints, Project.project_filepath("layers/application/extension_points")
      autoload :ProjectDependencies, Project.project_filepath("layers/application/project_dependencies")
    end

    module Domain
      autoload :Errors, Project.project_filepath("layers/domain/errors")
      autoload :PushPackage, Project.project_filepath("layers/domain/push_package")
      autoload :Metadata, Project.project_filepath("layers/domain/metadata")
      autoload :ExtensionPoint, Project.project_filepath("layers/domain/extension_point")
      autoload :ScriptJson, Project.project_filepath("layers/domain/script_json")
      autoload :ScriptProject, Project.project_filepath("layers/domain/script_project")
    end

    module Infrastructure
      autoload :ApiClients, Project.project_filepath("layers/infrastructure/api_clients")
      autoload :Errors, Project.project_filepath("layers/infrastructure/errors")
      autoload :CommandRunner, Project.project_filepath("layers/infrastructure/command_runner")
      autoload :PushPackageRepository, Project.project_filepath("layers/infrastructure/push_package_repository")
      autoload :ExtensionPointRepository, Project.project_filepath("layers/infrastructure/extension_point_repository")
      autoload :ScriptProjectRepository, Project.project_filepath("layers/infrastructure/script_project_repository")
      autoload :ScriptService, Project.project_filepath("layers/infrastructure/script_service")
      autoload :ScriptUploader, Project.project_filepath("layers/infrastructure/script_uploader")
      autoload :ServiceLocator, Project.project_filepath("layers/infrastructure/service_locator")

      module Languages
        autoload :AssemblyScriptProjectCreator,
          Project.project_filepath("layers/infrastructure/languages/assemblyscript_project_creator")
        autoload :AssemblyScriptTaskRunner,
          Project.project_filepath("layers/infrastructure/languages/assemblyscript_task_runner")
        autoload :ProjectCreator, Project.project_filepath("layers/infrastructure/languages/project_creator")
        autoload :RustProjectCreator,
          Project.project_filepath("layers/infrastructure/languages/rust_project_creator.rb")
        autoload :RustTaskRunner, Project.project_filepath("layers/infrastructure/languages/rust_task_runner")
        autoload :TaskRunner, Project.project_filepath("layers/infrastructure/languages/task_runner")
      end
    end
  end

  module UI
    autoload :ErrorHandler, Project.project_filepath("ui/error_handler")
    autoload :PrintingSpinner, Project.project_filepath("ui/printing_spinner")
    autoload :StrictSpinner, Project.project_filepath("ui/strict_spinner")
  end

  autoload :Errors, Project.project_filepath("errors")

  class ScriptProjectError < StandardError; end
end
