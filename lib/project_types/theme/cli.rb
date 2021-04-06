# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    title("Theme")
    connector("Theme::Command::Connect")

    register_task("Theme::Tasks::EnsureThemekitInstalled", :ensure_themekit_installed)

    require Project.project_filepath("messages/messages")
    register_messages(Theme::Messages::MESSAGES)
  end

  class Command < ShopifyCli::Command
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Deploy, "deploy", Project.project_filepath("commands/deploy")
    subcommand :Generate, "generate", Project.project_filepath("commands/generate")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")

    def call(*)
      @ctx.puts(self.class.help)
    end

    def self.help
      ShopifyCli::Context.message("theme.help", ShopifyCli::TOOL_NAME, subcommand_registry.command_names.join(" | "))
    end
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
