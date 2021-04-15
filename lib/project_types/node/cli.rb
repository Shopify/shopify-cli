# frozen_string_literal: true
module Node
  class Project < ShopifyCli::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Node::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command < ShopifyCli::ProjectCommands
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Deploy, "deploy", Project.project_filepath("commands/deploy")
    subcommand :Generate, "generate", Project.project_filepath("commands/generate")
    subcommand :Open, "open", Project.project_filepath("commands/open")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Tunnel, "tunnel", Project.project_filepath("commands/tunnel")
  end
  ShopifyCli::Commands.register("Node::Command", "node")

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
  end
end
