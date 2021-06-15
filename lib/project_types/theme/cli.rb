# frozen_string_literal: true
module Theme
  class Project < ShopifyCli::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Theme::Messages::MESSAGES)
  end

  class Command < ShopifyCli::ProjectCommands
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Check, "check", Project.project_filepath("commands/check")
    subcommand :Publish, "publish", Project.project_filepath("commands/publish")
    subcommand :Delete, "delete", Project.project_filepath("commands/delete")
    subcommand :Package, "package", Project.project_filepath("commands/package")
  end
  ShopifyCli::Commands.register("Theme::Command", "theme")

  module Forms
    autoload :ConfirmStore, Project.project_filepath("forms/confirm_store")
    autoload :Select, Project.project_filepath("forms/select")
  end
end
