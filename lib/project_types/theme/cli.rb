# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    hidden_feature

    title('Theme')
    creator('Theme::Commands::Create')
    connector('Theme::Commands::Connect')

    register_command('Theme::Commands::Deploy', "deploy")
    register_command('Theme::Commands::Push', "push")
    register_command('Theme::Commands::Serve', "serve")

    require Project.project_filepath('messages/messages')
    register_messages(Theme::Messages::MESSAGES)
  end

  module Commands
    autoload :Connect, Project.project_filepath('commands/connect')
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Deploy, Project.project_filepath('commands/deploy')
    autoload :Push, Project.project_filepath('commands/push')
    autoload :Serve, Project.project_filepath('commands/serve')
  end

  module Tasks
    autoload :EnsureThemekitInstalled, Project.project_filepath('tasks/ensure_themekit_installed')
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
    autoload :Connect, Project.project_filepath('forms/connect')
  end

  autoload :Themekit, Project.project_filepath('themekit')
end
