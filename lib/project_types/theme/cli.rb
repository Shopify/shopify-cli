# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    hidden_feature
    creator 'Theme App', 'Theme::Commands::Create'
    register_command('Theme::Commands::Serve', "serve")

    require Project.project_filepath('messages/messages')
    register_messages(Theme::Messages::MESSAGES)
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Serve, Project.project_filepath('commands/serve')
  end

  module Tasks
    autoload :EnsureThemekitInstalled, Project.project_filepath('tasks/ensure_themekit_installed')
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  autoload :Themekit, Project.project_filepath('themekit')
end
