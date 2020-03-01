module Rails
  class Project < ShopifyCli::ProjectType
    register_command('Rails::Commands::Serve', "serve")
    # register_task('Rails::Tasks::RailsTask', 'rails_task')
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Serve, Project.project_filepath('commands/serve')
  end

  # define/autoload project specific Tasks
  module Tasks
  end
end
