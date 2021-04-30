# frozen_string_literal: true

module Extension
  class PackageNotFound < RuntimeError; end

  class Project < ShopifyCli::ProjectType
    hidden_feature
    title("App Extension")
    creator("Extension::Commands::Create")

    register_command("Extension::Commands::Build", "build")
    register_command("Extension::Commands::Register", "register")
    register_command("Extension::Commands::Push", "push")
    register_command("Extension::Commands::Serve", "serve")
    register_command("Extension::Commands::Tunnel", "tunnel")

    require Project.project_filepath("messages/messages")
    require Project.project_filepath("messages/message_loading")
    require Project.project_filepath("extension_project_keys")
    register_messages(Extension::Messages::MessageLoading.load)
  end

  module Commands
    autoload :ExtensionCommand, Project.project_filepath("commands/extension_command")
    autoload :Create, Project.project_filepath("commands/create")
    autoload :Register, Project.project_filepath("commands/register")
    autoload :Build, Project.project_filepath("commands/build")
    autoload :Serve, Project.project_filepath("commands/serve")
    autoload :Push, Project.project_filepath("commands/push")
    autoload :Tunnel, Project.project_filepath("commands/tunnel")
  end

  module Tasks
    autoload :UserErrors, Project.project_filepath("tasks/user_errors")
    autoload :GetApps, Project.project_filepath("tasks/get_apps")
    autoload :GetApp, Project.project_filepath("tasks/get_app")
    autoload :CreateExtension, Project.project_filepath("tasks/create_extension")
    autoload :UpdateDraft, Project.project_filepath("tasks/update_draft")
    autoload :FetchSpecifications, Project.project_filepath("tasks/fetch_specifications")
    autoload :ConfigureFeatures, Project.project_filepath("tasks/configure_features")

    module Converters
      autoload :RegistrationConverter, Project.project_filepath("tasks/converters/registration_converter")
      autoload :VersionConverter, Project.project_filepath("tasks/converters/version_converter")
      autoload :ValidationErrorConverter, Project.project_filepath("tasks/converters/validation_error_converter")
      autoload :AppConverter, Project.project_filepath("tasks/converters/app_converter")
    end
  end

  module Forms
    module Questions
      autoload :AskApp, Project.project_filepath("forms/questions/ask_app")
      autoload :AskName, Project.project_filepath("forms/questions/ask_name")
      autoload :AskType, Project.project_filepath("forms/questions/ask_type")
    end

    autoload :Create, Project.project_filepath("forms/create")
    autoload :Register, Project.project_filepath("forms/register")
  end

  module Features
    autoload :ArgoRendererPackage, Project.project_filepath("features/argo_renderer_package")
    autoload :ArgoServe, Project.project_filepath("features/argo_serve")
    autoload :ArgoSetup, Project.project_filepath("features/argo_setup")
    autoload :ArgoSetupStep, Project.project_filepath("features/argo_setup_step")
    autoload :ArgoSetupSteps, Project.project_filepath("features/argo_setup_steps")
    autoload :ArgoDependencies, Project.project_filepath("features/argo_dependencies")
    autoload :ArgoConfig, Project.project_filepath("features/argo_config")
    autoload :Argo, Project.project_filepath("features/argo")
  end

  module Models
    module SpecificationHandlers
      autoload :Default, Project.project_filepath("models/specification_handlers/default")
    end

    autoload :App, Project.project_filepath("models/app")
    autoload :Registration, Project.project_filepath("models/registration")
    autoload :Version, Project.project_filepath("models/version")
    autoload :ValidationError, Project.project_filepath("models/validation_error")
    autoload :Specification, Project.project_filepath("models/specification")
    autoload :Specifications, Project.project_filepath("models/specifications")
    autoload :LazySpecificationHandler, Project.project_filepath("models/lazy_specification_handler")
  end

  autoload :ExtensionProjectKeys, Project.project_filepath("extension_project_keys")
  autoload :ExtensionProject, Project.project_filepath("extension_project")
end
