# frozen_string_literal: true

require "pathname"
require "json"
require "yaml"

module Extension
  class PackageResolutionFailed < RuntimeError; end

  class Project < ShopifyCLI::ProjectType
    hidden_feature

    require Project.project_filepath("messages/messages")
    require Project.project_filepath("messages/message_loading")
    require Project.project_filepath("extension_project_keys")
    register_messages(Extension::Messages::MessageLoading.load)
  end

  class Command < ShopifyCLI::Command::ProjectCommand
    autoload :ExtensionCommand, Project.project_filepath("commands/extension_command")

    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Register, "register", Project.project_filepath("commands/register")
    subcommand :Info, "info", Project.project_filepath("commands/info")
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Build, "build", Project.project_filepath("commands/build")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Tunnel, "tunnel", Project.project_filepath("commands/tunnel")
    subcommand :Check, "check", Project.project_filepath("commands/check")
  end
  ShopifyCLI::Commands.register("Extension::Command", "extension")

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
    autoload :GetProduct, Project.project_filepath("tasks/get_product")
    autoload :MergeServerConfig, Project.project_filepath("tasks/merge_server_config")
    autoload :FindPackageFromJson, Project.project_filepath("tasks/find_package_from_json.rb")
    autoload :EnsureResourceUrl, Project.project_filepath("tasks/ensure_resource_url.rb")
    autoload :ConvertServerConfig, Project.project_filepath("tasks/convert_server_config")

    module Converters
      autoload :RegistrationConverter, Project.project_filepath("tasks/converters/registration_converter")
      autoload :VersionConverter, Project.project_filepath("tasks/converters/version_converter")
      autoload :ValidationErrorConverter, Project.project_filepath("tasks/converters/validation_error_converter")
      autoload :AppConverter, Project.project_filepath("tasks/converters/app_converter")
      autoload :ProductConverter, Project.project_filepath("tasks/converters/product_converter")
      autoload :ExecuteCommands, Project.project_filepath("cli/execute_commands")
    end

    module ExecuteCommands
      autoload :Base, Project.project_filepath("tasks/execute_commands/base")
      autoload :Build, Project.project_filepath("tasks/execute_commands/build")
      autoload :Create, Project.project_filepath("tasks/execute_commands/create")
      autoload :Serve, Project.project_filepath("tasks/execute_commands/serve")
      autoload :OutdatedExtensionDetection,
        Project.project_filepath("tasks/execute_commands/outdated_extension_detection")

      class << self
        def build(*args)
          Build.new(*args).call
        end

        def create(*args)
          Create.new(*args).call
        end

        def serve(*args)
          Serve.new(*args).call
        end
      end
    end
  end

  module Forms
    module Questions
      autoload :AskApp, Project.project_filepath("forms/questions/ask_app")
      autoload :AskName, Project.project_filepath("forms/questions/ask_name")
      autoload :AskTemplate, Project.project_filepath("forms/questions/ask_template")
      autoload :AskType, Project.project_filepath("forms/questions/ask_type")
      autoload :AskRegistration, Project.project_filepath("forms/questions/ask_registration")
    end

    autoload :Create, Project.project_filepath("forms/create")
    autoload :Register, Project.project_filepath("forms/register")
    autoload :Connect, Project.project_filepath("forms/connect")
  end

  module Features
    module Runtimes
      autoload :Admin, Project.project_filepath("features/runtimes/admin")
      autoload :Base, Project.project_filepath("features/runtimes/base")
      autoload :CheckoutPostPurchase, Project.project_filepath("features/runtimes/checkout_post_purchase")
      autoload :CheckoutUiExtension, Project.project_filepath("features/runtimes/checkout_ui_extension")
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
    end

    module ServerConfig
      autoload :Base, Project.project_filepath("models/server_config/base")
      autoload :App, Project.project_filepath("models/server_config/app")
      autoload :Capabilities, Project.project_filepath("models/server_config/capabilities")
      autoload :Development, Project.project_filepath("models/server_config/development")
      autoload :DevelopmentEntries, Project.project_filepath("models/server_config/development_entries")
      autoload :DevelopmentRenderer, Project.project_filepath("models/server_config/development_renderer")
      autoload :DevelopmentResource, Project.project_filepath("models/server_config/development_resource")
      autoload :Extension, Project.project_filepath("models/server_config/extension")
      autoload :Root, Project.project_filepath("models/server_config/root")
      autoload :User, Project.project_filepath("models/server_config/user")
    end

    autoload :App, Project.project_filepath("models/app")
    autoload :Registration, Project.project_filepath("models/registration")
    autoload :Version, Project.project_filepath("models/version")
    autoload :ValidationError, Project.project_filepath("models/validation_error")
    autoload :Specification, Project.project_filepath("models/specification")
    autoload :Specifications, Project.project_filepath("models/specifications")
    autoload :LazySpecificationHandler, Project.project_filepath("models/lazy_specification_handler")
    autoload :NpmPackage, Project.project_filepath("models/npm_package")
    autoload :Product, Project.project_filepath("models/product")
    autoload :DevelopmentServer, Project.project_filepath("models/development_server")
    autoload :DevelopmentServerRequirements, Project.project_filepath("models/development_server_requirements")
  end

  autoload :ExtensionProjectKeys, Project.project_filepath("extension_project_keys")
  autoload :ExtensionProject, Project.project_filepath("extension_project")
  autoload :Errors, Project.project_filepath("errors")

  module Loaders
    autoload :Project, Extension::Project.project_filepath("loaders/project")
    autoload :SpecificationHandler, Extension::Project.project_filepath("loaders/specification_handler")
  end
end
