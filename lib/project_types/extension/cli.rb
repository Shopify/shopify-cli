# frozen_string_literal: true

module Extension
  class PackageResolutionFailed < RuntimeError; end

  class Project < ShopifyCli::ProjectType
    hidden_feature

    require Project.project_filepath("messages/messages")
    require Project.project_filepath("messages/message_loading")
    require Project.project_filepath("extension_project_keys")
    register_messages(Extension::Messages::MessageLoading.load)
  end

  class Command < ShopifyCli::ProjectCommands
    hidden_feature
    autoload :ExtensionCommand, Project.project_filepath("commands/extension_command")

    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Register, "register", Project.project_filepath("commands/register")
    subcommand :Info, "info", Project.project_filepath("commands/info")
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Build, "build", Project.project_filepath("commands/build")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Tunnel, "tunnel", Project.project_filepath("commands/tunnel")
  end
  ShopifyCli::Commands.register("Extension::Command", "extension")

  module Tasks
    autoload :UserErrors, Project.project_filepath("tasks/user_errors")
    autoload :GetApps, Project.project_filepath("tasks/get_apps")
    autoload :GetApp, Project.project_filepath("tasks/get_app")
    autoload :CreateExtension, Project.project_filepath("tasks/create_extension")
    autoload :UpdateDraft, Project.project_filepath("tasks/update_draft")
    autoload :FetchSpecifications, Project.project_filepath("tasks/fetch_specifications")
    autoload :ConfigureFeatures, Project.project_filepath("tasks/configure_features")
    autoload :ConfigureOptions, Project.project_filepath("tasks/configure_options")
    autoload :ChooseNextAvailablePort, Project.project_filepath("tasks/choose_next_available_port")
    autoload :FindNpmPackages, Project.project_filepath("tasks/find_npm_packages")
    autoload :GetExtensions, Project.project_filepath("tasks/get_extensions")

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
      autoload :AskRegistration, Project.project_filepath("forms/questions/ask_registration")
    end

    autoload :Create, Project.project_filepath("forms/create")
    autoload :Register, Project.project_filepath("forms/register")
    autoload :Connect, Project.project_filepath("forms/connect")
  end

  module Features
    module Runtimes
      autoload :AdminRuntime, Project.project_filepath("features/runtimes/admin_runtime")
      autoload :CheckoutRuntime, Project.project_filepath("features/runtimes/checkout_runtime")
      autoload :CheckoutPostPurchaseRuntime, Project.project_filepath(
        "features/runtimes/checkout_post_purchase_runtime"
      )
    end
    autoload :ArgoServe, Project.project_filepath("features/argo_serve")
    autoload :ArgoServeOptions, Project.project_filepath("features/argo_serve_options")
    autoload :ArgoSetup, Project.project_filepath("features/argo_setup")
    autoload :ArgoSetupStep, Project.project_filepath("features/argo_setup_step")
    autoload :ArgoSetupSteps, Project.project_filepath("features/argo_setup_steps")
    autoload :ArgoDependencies, Project.project_filepath("features/argo_dependencies")
    autoload :ArgoConfig, Project.project_filepath("features/argo_config")
    autoload :ArgoRuntime, Project.project_filepath("features/argo_runtime")
    autoload :Argo, Project.project_filepath("features/argo")
  end

  module Models
    module SpecificationHandlers
      autoload :Default, Project.project_filepath("models/specification_handlers/default")
      autoload :CheckoutArgoExtension, Project.project_filepath("models/specification_handlers/checkout_ui_extension")
    end

    autoload :App, Project.project_filepath("models/app")
    autoload :Registration, Project.project_filepath("models/registration")
    autoload :Version, Project.project_filepath("models/version")
    autoload :ValidationError, Project.project_filepath("models/validation_error")
    autoload :Specification, Project.project_filepath("models/specification")
    autoload :Specifications, Project.project_filepath("models/specifications")
    autoload :LazySpecificationHandler, Project.project_filepath("models/lazy_specification_handler")
    autoload :NpmPackage, Project.project_filepath("models/npm_package")
  end

  autoload :ExtensionProjectKeys, Project.project_filepath("extension_project_keys")
  autoload :ExtensionProject, Project.project_filepath("extension_project")
  autoload :Errors, Project.project_filepath("errors")
end
