# frozen_string_literal: true

module Script
  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Script', 'Script::Commands::Create'

    register_command('Script::Commands::Deploy', 'deploy')
    register_command('Script::Commands::Enable', 'enable')
    register_command('Script::Commands::Test', 'test')

    require Project.project_filepath('messages/messages')
    register_messages(Script::Messages::MESSAGES)
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Deploy, Project.project_filepath('commands/deploy')
    autoload :Enable, Project.project_filepath('commands/enable')
    autoload :Test, Project.project_filepath('commands/test')
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath('forms/create')
    autoload :Deploy, Project.project_filepath('forms/deploy')
    autoload :Enable, Project.project_filepath('forms/enable')
    autoload :ScriptForm, Project.project_filepath('forms/script_form')
  end

  module Layers
    module Application
      autoload :BuildScript, Project.project_filepath('layers/application/build_script')
      autoload :CreateScript, Project.project_filepath('layers/application/create_script')
      autoload :DeployScript, Project.project_filepath('layers/application/deploy_script')
      autoload :EnableScript, Project.project_filepath('layers/application/enable_script')
      autoload :ExtensionPoints, Project.project_filepath('layers/application/extension_points')
      autoload :ProjectDependencies, Project.project_filepath('layers/application/project_dependencies')
      autoload :TestScript, Project.project_filepath('layers/application/test_script')
    end

    module Domain
      autoload :Errors, Project.project_filepath('layers/domain/errors')
      autoload :DeployPackage, Project.project_filepath('layers/domain/deploy_package')
      autoload :ExtensionPoint, Project.project_filepath('layers/domain/extension_point')
      autoload :Script, Project.project_filepath('layers/domain/script')
    end

    module Infrastructure
      autoload :Errors, Project.project_filepath('layers/infrastructure/errors')
      autoload :AssemblyScriptDependencyManager,
               Project.project_filepath('layers/infrastructure/assemblyscript_dependency_manager')
      autoload :AssemblyScriptTestRunner,
               Project.project_filepath('layers/infrastructure/assemblyscript_test_runner')
      autoload :AssemblyScriptTsConfig, Project.project_filepath('layers/infrastructure/assemblyscript_tsconfig')
      autoload :AssemblyScriptWasmBuilder,
               Project.project_filepath('layers/infrastructure/assemblyscript_wasm_builder')
      autoload :DependencyManager, Project.project_filepath('layers/infrastructure/dependency_manager')
      autoload :DeployPackageRepository, Project.project_filepath('layers/infrastructure/deploy_package_repository')
      autoload :ExtensionPointRepository, Project.project_filepath('layers/infrastructure/extension_point_repository')
      autoload :ScriptBuilder, Project.project_filepath('layers/infrastructure/script_builder')
      autoload :ScriptRepository, Project.project_filepath('layers/infrastructure/script_repository')
      autoload :ScriptService, Project.project_filepath('layers/infrastructure/script_service')
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
