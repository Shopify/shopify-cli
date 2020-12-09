# frozen_string_literal: true
module Rails
  class Project < ShopifyCli::ProjectType
    title('Ruby on Rails App')
    creator('Rails::Commands::Create')
    connector('Rails::Commands::Connect')

    register_command('Rails::Commands::Deploy', "deploy")
    register_command('Rails::Commands::Generate', "generate")
    register_command('Rails::Commands::Open', "open")
    register_command('Rails::Commands::Populate', "populate")
    register_command('Rails::Commands::Serve', "serve")
    register_command('Rails::Commands::Tunnel', "tunnel")
    # register_task('Rails::Tasks::RailsTask', 'rails_task')

    require Project.project_filepath('messages/messages')
    register_messages(Rails::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Connect, Project.project_filepath('commands/connect')
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Deploy, Project.project_filepath('commands/deploy')
    autoload :Generate, Project.project_filepath('commands/generate')
    autoload :Open, Project.project_filepath('commands/open')
    autoload :Populate, Project.project_filepath('commands/populate')
    autoload :Serve, Project.project_filepath('commands/serve')
    autoload :Tunnel, Project.project_filepath('commands/tunnel')
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  autoload :Ruby, Project.project_filepath('ruby')
  autoload :Gem, Project.project_filepath('gem')
end
