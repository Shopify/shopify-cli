# frozen_string_literal: true
module PHP
  class Project < ShopifyCli::ProjectType
    title("PHP App")
    creator("PHP::Commands::Create")
    connector("PHP::Commands::Connect")

    register_command("PHP::Commands::Serve", "serve")
    register_command("PHP::Commands::Tunnel", "tunnel")

    require Project.project_filepath("messages/messages")
    register_messages(PHP::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Create, Project.project_filepath("commands/create")
    autoload :Serve, Project.project_filepath("commands/serve")
    autoload :Tunnel, Project.project_filepath("commands/tunnel")
    autoload :Connect, Project.project_filepath("commands/connect")
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
  end
end
