# frozen_string_literal: true
module Extension
  class Project < ShopifyCli::ProjectType
    creator 'App Extension', 'Extension::Commands::Create'

    register_command('Extension::Commands::Pack', "pack")
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Pack, Project.project_filepath('commands/pack')
  end

  module Tasks
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  autoload :JsDeps, Project.project_filepath('js_deps')
end
