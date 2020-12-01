# frozen_string_literal: true
module Node
  class Project < ShopifyCli::ProjectType
    title('Node.js App')
    creator('Node::Commands::Create')
    connector('Node::Commands::Connect')

    register_command('Node::Commands::Deploy', "deploy")
    register_command('Node::Commands::Generate', "generate")
    register_command('Node::Commands::Open', "open")
    register_command('Node::Commands::Populate', "populate")
    register_command('Node::Commands::Serve', "serve")
    register_command('Node::Commands::Tunnel', "tunnel")
    # register_task('Node::Tasks::NodeTask', 'node_task')

    require Project.project_filepath('messages/messages')
    register_messages(Node::Messages::MESSAGES)
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
end
