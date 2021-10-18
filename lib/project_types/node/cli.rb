# frozen_string_literal: true
module Node
  class Project < ShopifyCLI::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Node::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command
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
