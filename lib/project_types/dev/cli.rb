# frozen_string_literal: true
module Dev
  class Project < ShopifyCli::ProjectType
    declare("Freeform App")
    register_command('Dev::Commands::Populate', "populate")
    register_command('Dev::Commands::Serve', "serve")
    register_command('Dev::Commands::Tunnel', "tunnel")

    require Project.project_filepath('messages/messages')
    register_messages(Dev::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Populate, Project.project_filepath('commands/populate')
    autoload :Serve, Project.project_filepath('commands/serve')
    autoload :Tunnel, Project.project_filepath('commands/tunnel')
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
  end
end
