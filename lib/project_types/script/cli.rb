# frozen_string_literal: true

module Script
  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Script', 'Script::Commands::Create'

    register_command('Script::Commands::Test', 'test')
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Test, Project.project_filepath('commands/test')
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
      autoload :TestScript, Project.project_filepath('layers/application/test_script')
    end

    module Domain
      autoload :Errors, Project.project_filepath('layers/domain/errors')
      autoload :ExtensionPoint, Project.project_filepath('layers/domain/extension_point')
      autoload :Script, Project.project_filepath('layers/domain/script')
    end

    module Infrastructure
      autoload :Errors, Project.project_filepath('layers/infrastructure/errors')
      autoload :AssemblyScriptTsConfig, Project.project_filepath('layers/infrastructure/assemblyscript_tsconfig')
      autoload :AssemblyScriptDependencyManager,
               Project.project_filepath('layers/infrastructure/assemblyscript_dependency_manager')
      autoload :AssemblyScriptTestRunner,
               Project.project_filepath('layers/infrastructure/assemblyscript_test_runner')
      autoload :DependencyManager, Project.project_filepath('layers/infrastructure/dependency_manager')
      autoload :ExtensionPointRepository, Project.project_filepath('layers/infrastructure/extension_point_repository')
      autoload :ScriptRepository, Project.project_filepath('layers/infrastructure/script_repository')
      autoload :TestSuiteRepository, Project.project_filepath('layers/infrastructure/test_suite_repository')
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
