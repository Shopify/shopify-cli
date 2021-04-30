# frozen_string_literal: true
module PHP
  class Project < ShopifyCli::ProjectType
    title("PHP App")
    creator("PHP::Commands::Create")
    # connector("PHP::Commands::Connect")

    # register_command("Node::Commands::Deploy", "deploy")

    require Project.project_filepath("messages/messages")
    register_messages(PHP::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  module Commands
    autoload :Create, Project.project_filepath("commands/create")
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
  end
end
