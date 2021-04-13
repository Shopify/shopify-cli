# frozen_string_literal: true
module Node
  class Project < ShopifyCli::ProjectType
    title("Node.js App")
    connector("Node::Command::Connect")

    # register_task('Node::Tasks::NodeTask', 'node_task')

    require Project.project_filepath("messages/messages")
    register_messages(Node::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command < ShopifyCli::Command
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Deploy, "deploy", Project.project_filepath("commands/deploy")
    subcommand :Generate, "generate", Project.project_filepath("commands/generate")
    subcommand :Open, "open", Project.project_filepath("commands/open")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Tunnel, "tunnel", Project.project_filepath("commands/tunnel")

    def call(*)
      @ctx.puts(self.class.help)
    end

    def self.help
      ShopifyCli::Context.message("node.help", ShopifyCli::TOOL_NAME, subcommand_registry.command_names.join(" | "))
    end
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
