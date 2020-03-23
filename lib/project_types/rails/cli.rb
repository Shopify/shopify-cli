# frozen_string_literal: true
module Rails
  class Project < ShopifyCli::ProjectType
    # hidden_project_type
    creator 'Ruby on Rails App', 'Rails::Commands::Create'

    register_command('Rails::Commands::Open', "open")
    register_command('Rails::Commands::Serve', "serve")
    register_command('Rails::Commands::Generate', "generate")
    # register_task('Rails::Tasks::RailsTask', 'rails_task')
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Open, Project.project_filepath('commands/open')
    autoload :Generate, Project.project_filepath('commands/generate')
    autoload :Serve, Project.project_filepath('commands/serve')
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
