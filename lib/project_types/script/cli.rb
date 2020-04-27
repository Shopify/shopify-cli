# frozen_string_literal: true

module Script
  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Script', 'Script::Commands::Create'
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  module Layers
    module Application
      autoload :CreateScript, Project.project_filepath('layers/application/create_script')
      autoload :ExtensionPoints, Project.project_filepath('layers/application/extension_points')
      autoload :ProjectDependencies, Project.project_filepath('layers/application/project_dependencies')
    end

    module Domain
      autoload :ExtensionPoint, Project.project_filepath('layers/domain/extension_point')
      autoload :Script, Project.project_filepath('layers/domain/script')

      # errors
      autoload :InvalidExtensionPointError,
               Project.project_filepath('layers/domain/errors/invalid_extension_point_error')
      autoload :ScriptNotFoundError, Project.project_filepath('layers/domain/errors/script_not_found_error')
      autoload :ServiceFailureError, Project.project_filepath('layers/domain/errors/service_failure_error')
      autoload :TestSuiteNotFoundError, Project.project_filepath('layers/domain/errors/test_suite_not_found_error')
    end

    module Infrastructure
      autoload :AssemblyScriptTsConfig, Project.project_filepath('layers/infrastructure/assemblyscript_tsconfig')
      autoload :AssemblyScriptDependencyManager,
               Project.project_filepath('layers/infrastructure/assemblyscript_dependency_manager')
      autoload :DependencyManager, Project.project_filepath('layers/infrastructure/dependency_manager')
      autoload :ExtensionPointRepository, Project.project_filepath('layers/infrastructure/extension_point_repository')
      autoload :ScriptRepository, Project.project_filepath('layers/infrastructure/script_repository')
      autoload :TestSuiteRepository, Project.project_filepath('layers/infrastructure/test_suite_repository')

      # errors
      autoload :DependencyError, Project.project_filepath('layers/infrastructure/errors/dependency_error')
      autoload :DependencyInstallError,
               Project.project_filepath('layers/infrastructure/errors/dependency_install_error')
    end
  end

  module UI
    autoload :ErrorHandler, Project.project_filepath('ui/error_handler')
    autoload :StrictSpinner, Project.project_filepath('ui/strict_spinner')
  end

  autoload :ScriptProject, Project.project_filepath('script_project')
  autoload :InvalidScriptProjectContextError,
           Project.project_filepath('errors/invalid_script_project_context_error')
  autoload :ScriptProjectAlreadyExistsError, Project.project_filepath('errors/script_project_already_exists_error')
end
