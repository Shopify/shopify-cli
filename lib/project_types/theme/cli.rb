# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Theme App', 'Theme::Commands::Create'
  end

  module Commands
  end

  module Tasks
    autoload :EnsureThemekitInstalled, Project.project_filepath('tasks/ensure_themekit_installed')
  end

  module Forms
  end
end
