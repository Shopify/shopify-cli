# frozen_string_literal: true
module Extension
  class Project < ShopifyCli::ProjectType
    creator 'App Extension', 'Extension::Commands::Create'

    register_command('Extension::Commands::Pack', "pack")
    register_command('Extension::Commands::Deploy', "deploy")
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Pack, Project.project_filepath('commands/pack')
    autoload :Deploy, Project.project_filepath('commands/deploy')
  end

  module Tasks
    autoload :CreateExtension, Project.project_filepath('tasks/create_extension')
    autoload :UpdateDraft, Project.project_filepath('tasks/update_draft')
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  module Models
    autoload :Registration, Project.project_filepath('models/registration')
    autoload :Version, Project.project_filepath('models/version')
  end

  autoload :JsDeps, Project.project_filepath('js_deps')
  autoload :ExtensionProject, Project.project_filepath('extension_project')
end
