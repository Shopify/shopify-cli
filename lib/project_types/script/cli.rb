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
    end

    module Infrastructure
      autoload :AssemblyScriptTsConfig, Project.project_filepath('layers/infrastructure/assemblyscript_tsconfig')
      autoload :AssemblyScriptDependencyManager,
               Project.project_filepath('layers/infrastructure/assemblyscript_dependency_manager')
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

  class ScriptProjectError < StandardError; end
  class InvalidContextError < ScriptProjectError; end
  class ScriptProjectAlreadyExistsError < ScriptProjectError; end
  class ServiceFailureError < ScriptProjectError; end
  class TestSuiteNotFoundError < ScriptProjectError; end
  class DependencyError < ScriptProjectError; end
  class DependencyInstallError < ScriptProjectError; end
  class InvalidExtensionPointError < ScriptProjectError
    attr_reader :type
    def initialize(type)
      @type = type
    end
  end
  class ScriptNotFoundError < ScriptProjectError
    attr_reader :script_name, :extension_point_type
    def initialize(extension_point_type, script_name)
      @script_name = script_name
      @extension_point_type = extension_point_type
    end
  end
end
