# frozen_string_literal: true
module PHP
  class Project < ShopifyCLI::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(PHP::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command < ShopifyCLI::ProjectCommands
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Deploy, "deploy", Project.project_filepath("commands/deploy")
    subcommand :Open, "open", Project.project_filepath("commands/open")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Tunnel, "tunnel", Project.project_filepath("commands/tunnel")
  end
  ShopifyCLI::Commands.register("PHP::Command", "php")

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
  end
end
