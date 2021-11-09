# frozen_string_literal: true
module Rails
  class Project < ShopifyCLI::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Rails::Messages::MESSAGES)
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath("forms/create")
  end

  autoload :Ruby, Project.project_filepath("ruby")
  autoload :Gem, Project.project_filepath("gem")
end
