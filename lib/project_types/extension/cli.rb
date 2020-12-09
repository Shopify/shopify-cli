# frozen_string_literal: true

module Extension
  class Project < ShopifyCli::ProjectType
    hidden_feature
    title('App Extension')
    creator('Extension::Commands::Create')

    register_command('Extension::Commands::Build', "build")
    register_command('Extension::Commands::Register', "register")
    register_command('Extension::Commands::Push', "push")
    register_command('Extension::Commands::Serve', "serve")
    register_command('Extension::Commands::Tunnel', "tunnel")

    require Project.project_filepath('messages/messages')
    require Project.project_filepath('messages/message_loading')
    require Project.project_filepath('extension_project_keys')
    register_messages(Extension::Messages::MessageLoading.load)
  end

  module Commands
    autoload :ExtensionCommand, Project.project_filepath('commands/extension_command')
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Register, Project.project_filepath('commands/register')
    autoload :Build, Project.project_filepath('commands/build')
    autoload :Serve, Project.project_filepath('commands/serve')
    autoload :Push, Project.project_filepath('commands/push')
    autoload :Tunnel, Project.project_filepath('commands/tunnel')
  end

  module Tasks
    autoload :UserErrors, Project.project_filepath('tasks/user_errors')
    autoload :GetApps, Project.project_filepath('tasks/get_apps')
    autoload :GetApp, Project.project_filepath('tasks/get_app')
    autoload :CreateExtension, Project.project_filepath('tasks/create_extension')
    autoload :UpdateDraft, Project.project_filepath('tasks/update_draft')

    module Converters
      autoload :RegistrationConverter, Project.project_filepath('tasks/converters/registration_converter')
      autoload :VersionConverter, Project.project_filepath('tasks/converters/version_converter')
      autoload :ValidationErrorConverter, Project.project_filepath('tasks/converters/validation_error_converter')
      autoload :AppConverter, Project.project_filepath('tasks/converters/app_converter')
    end
  end

  module Forms
    autoload :Create, Project.project_filepath('forms/create')
    autoload :Register, Project.project_filepath('forms/register')
  end

  module Features
    autoload :ArgoSetup, Project.project_filepath('features/argo_setup')
    autoload :ArgoSetupStep, Project.project_filepath('features/argo_setup_step')
    autoload :ArgoSetupSteps, Project.project_filepath('features/argo_setup_steps')
    autoload :ArgoDependencies, Project.project_filepath('features/argo_dependencies')
    autoload :ArgoConfig, Project.project_filepath('features/argo_config')
    module Argo
      autoload :Base, Project.project_filepath('features/argo/base')
      autoload :Admin, Project.project_filepath('features/argo/admin')
      autoload :Checkout, Project.project_filepath('features/argo/checkout')
    end
  end

  module Models
    autoload :App, Project.project_filepath('models/app')
    autoload :Registration, Project.project_filepath('models/registration')
    autoload :Version, Project.project_filepath('models/version')
    autoload :Type, Project.project_filepath('models/type')
    autoload :ValidationError, Project.project_filepath('models/validation_error')

    class << self
      Models::Type.load_all
    end
  end

  autoload :ExtensionProjectKeys, Project.project_filepath('extension_project_keys')
  autoload :ExtensionProject, Project.project_filepath('extension_project')
end
