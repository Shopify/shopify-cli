# frozen_string_literal: true

module Script
  class Project < ShopifyCli::ProjectType
    hidden_feature(feature_set: :script_project)
    title("Script")
    creator("Script::Commands::Create")

    register_command("Script::Commands::Push", "push")

    require Project.project_filepath("messages/messages")
    register_messages(Script::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Create, Project.project_filepath("commands/create")
    autoload :Push, Project.project_filepath("commands/push")
  end

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
      autoload :ConfigUi, Project.project_filepath("layers/domain/config_ui")
      autoload :PushPackage, Project.project_filepath("layers/domain/push_package")
      autoload :Metadata, Project.project_filepath("layers/domain/metadata")
      autoload :ExtensionPoint, Project.project_filepath("layers/domain/extension_point")
      autoload :ScriptProject, Project.project_filepath("layers/domain/script_project")
    end

    module Infrastructure
      autoload :Errors, Project.project_filepath("layers/infrastructure/errors")
      autoload :AssemblyScriptDependencyManager,
        Project.project_filepath("layers/infrastructure/assemblyscript_dependency_manager")
      autoload :AssemblyScriptProjectCreator,
        Project.project_filepath("layers/infrastructure/assemblyscript_project_creator")
      autoload :AssemblyScriptTaskRunner, Project.project_filepath("layers/infrastructure/assemblyscript_task_runner")
      autoload :AssemblyScriptTsConfig, Project.project_filepath("layers/infrastructure/assemblyscript_tsconfig")
      autoload :CommandRunner, Project.project_filepath("layers/infrastructure/command_runner")
      autoload :RustProjectCreator,
        Project.project_filepath("layers/infrastructure/rust_project_creator.rb")
      autoload :RustTaskRunner, Project.project_filepath("layers/infrastructure/rust_task_runner")

      autoload :PushPackageRepository, Project.project_filepath("layers/infrastructure/push_package_repository")
      autoload :ExtensionPointRepository, Project.project_filepath("layers/infrastructure/extension_point_repository")
      autoload :ProjectCreator, Project.project_filepath("layers/infrastructure/project_creator")
      autoload :ScriptProjectRepository, Project.project_filepath("layers/infrastructure/script_project_repository")
      autoload :ScriptService, Project.project_filepath("layers/infrastructure/script_service")
      autoload :TaskRunner, Project.project_filepath("layers/infrastructure/task_runner")
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
