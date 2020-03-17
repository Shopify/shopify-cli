# frozen_string_literal: true
module Node
  class Project < ShopifyCli::ProjectType
    creator 'Node.js App', 'Node::Commands::Create'

    register_command('Node::Commands::Open', "open")
    register_command('Node::Commands::Generate', "generate")
    register_command('Node::Commands::Serve', "serve")
    # register_task('Node::Tasks::NodeTask', 'node_task')
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

  autoload :JsDeps, Project.project_filepath('js_deps')
end
