# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Theme::Messages::MESSAGES)
  end

  class Command < ShopifyCli::ProjectCommands
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Deploy, "deploy", Project.project_filepath("commands/deploy")
    subcommand :Generate, "generate", Project.project_filepath("commands/generate")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Check, "check", Project.project_filepath("commands/check")
  end
  ShopifyCli::Commands.register("Theme::Command", "theme")

  module Tasks
    autoload :EnsureThemekitInstalled, Project.project_filepath("tasks/ensure_themekit_installed")
  end

  module Forms
    autoload :Create, Project.project_filepath("forms/create")
    autoload :Connect, Project.project_filepath("forms/connect")
  end

  autoload :Themekit, Project.project_filepath("themekit")
end
