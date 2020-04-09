# frozen_string_literal: true
module Extension
  class Project < ShopifyCli::ProjectType
    creator 'App Extension', 'Extension::Commands::Create'
  end

  module Commands
    autoload :Create, Project.project_filepath('commands/create')
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  autoload :JsDeps, Project.project_filepath('js_deps')
end
