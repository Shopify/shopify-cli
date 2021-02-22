# frozen_string_literal: true

module AppConfig
  class Project < ShopifyCli::ProjectType
    hidden_feature
    title('App Config')
    creator('AppConfig::Commands::Create')

    require Project.project_filepath('messages/messages')
    register_messages(AppConfig::Messages::MESSAGES)
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
  end

  module Tasks
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end
end
