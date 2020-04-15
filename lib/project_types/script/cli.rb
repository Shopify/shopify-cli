# frozen_string_literal: true
module Script
  SUPPORTED_LANGUAGES = %w(ts)

  class Project < ShopifyCli::ProjectType
    hidden_project_type
    creator 'Script', 'Script::Commands::Create'
  end

  # define/autoload project specific Commads
  module Commands
    autoload :Create, Project.project_filepath('commands/create')
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
    autoload :Create, Project.project_filepath('forms/create')
  end

  module Layers
    module Application
      autoload :ExtensionPoints, Project.project_filepath('layers/application/extension_points')
    end

    module Domain
      autoload :ExtensionPoint, Project.project_filepath('layers/domain/extension_point')
      autoload :InvalidExtensionPointError,
               Project.project_filepath('layers/domain/errors/invalid_extension_point_error.rb')
    end

    module Infrastructure
      autoload :ExtensionPointRepository, Project.project_filepath('layers/infrastructure/extension_point_repository')
      autoload :Repository, Project.project_filepath('layers/infrastructure/repository')
    end
  end
end
