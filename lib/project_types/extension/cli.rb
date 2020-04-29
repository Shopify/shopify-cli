# frozen_string_literal: true
module Extension
  class Project < ShopifyCli::ProjectType
    creator 'App Extension', 'Extension::Commands::Create'

    register_command('Extension::Commands::Pack', "pack")
    register_command('Extension::Commands::Push', "push")
    register_command('Extension::Commands::Serve', "serve")
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Pack, Project.project_filepath('commands/pack')
    autoload :Serve, Project.project_filepath('commands/serve')
    autoload :Push, Project.project_filepath('commands/push')
  end

  module Tasks
    autoload :UserErrors, Project.project_filepath('tasks/user_errors')
    autoload :GetApps, Project.project_filepath('tasks/get_apps')
    autoload :CreateExtension, Project.project_filepath('tasks/create_extension')
    autoload :UpdateDraft, Project.project_filepath('tasks/update_draft')
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  module Models
    autoload :App, Project.project_filepath('models/app')
    autoload :Registration, Project.project_filepath('models/registration')
    autoload :Version, Project.project_filepath('models/version')
    autoload :Type, Project.project_filepath('models/type')

    class << self
      Models::Type.load_all
    end
  end

  autoload :JsDeps, Project.project_filepath('js_deps')
  autoload :ExtensionProject, Project.project_filepath('extension_project')
  autoload :Content, Project.project_filepath('content')
end
