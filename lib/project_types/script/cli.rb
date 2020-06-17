# frozen_string_literal: true

module Script
  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Script', 'Script::Commands::Create'

    register_command('Script::Commands::Push', 'push')
    register_command('Script::Commands::Disable', 'disable')
    register_command('Script::Commands::Enable', 'enable')

    require Project.project_filepath('messages/messages')
    register_messages(Script::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Push, Project.project_filepath('commands/push')
    autoload :Disable, Project.project_filepath('commands/disable')
    autoload :Enable, Project.project_filepath('commands/enable')
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath('forms/create')
    autoload :Push, Project.project_filepath('forms/push')
    autoload :Enable, Project.project_filepath('forms/enable')
    autoload :ScriptForm, Project.project_filepath('forms/script_form')
  end

  module Layers
    module Application
      autoload :BuildScript, Project.project_filepath('layers/application/build_script')
      autoload :CreateScript, Project.project_filepath('layers/application/create_script')
      autoload :PushScript, Project.project_filepath('layers/application/push_script')
      autoload :DisableScript, Project.project_filepath('layers/application/disable_script')
      autoload :EnableScript, Project.project_filepath('layers/application/enable_script')
      autoload :ExtensionPoints, Project.project_filepath('layers/application/extension_points')
      autoload :ProjectDependencies, Project.project_filepath('layers/application/project_dependencies')
    end

    module Domain
      autoload :Errors, Project.project_filepath('layers/domain/errors')
      autoload :PushPackage, Project.project_filepath('layers/domain/push_package')
      autoload :ExtensionPoint, Project.project_filepath('layers/domain/extension_point')
      autoload :Script, Project.project_filepath('layers/domain/script')
    end

    module Infrastructure
      autoload :Errors, Project.project_filepath('layers/infrastructure/errors')
      autoload :AssemblyScriptDependencyManager,
               Project.project_filepath('layers/infrastructure/assemblyscript_dependency_manager')
      autoload :AssemblyScriptProjectCreator,
               Project.project_filepath('layers/infrastructure/assemblyscript_project_creator')
      autoload :AssemblyScriptTaskRunner, Project.project_filepath('layers/infrastructure/assemblyscript_task_runner')
      autoload :AssemblyScriptTsConfig, Project.project_filepath('layers/infrastructure/assemblyscript_tsconfig')
      autoload :PushPackageRepository, Project.project_filepath('layers/infrastructure/push_package_repository')
      autoload :ExtensionPointRepository, Project.project_filepath('layers/infrastructure/extension_point_repository')
      autoload :ProjectCreator, Project.project_filepath('layers/infrastructure/project_creator')
      autoload :ScriptRepository, Project.project_filepath('layers/infrastructure/script_repository')
      autoload :ScriptService, Project.project_filepath('layers/infrastructure/script_service')
      autoload :TaskRunner, Project.project_filepath('layers/infrastructure/task_runner')
    end
  end

  module UI
    autoload :ErrorHandler, Project.project_filepath('ui/error_handler')
    autoload :StrictSpinner, Project.project_filepath('ui/strict_spinner')
  end

  autoload :ScriptProject, Project.project_filepath('script_project')
  autoload :Errors, Project.project_filepath('errors')

  class ScriptProjectError < StandardError; end
end
