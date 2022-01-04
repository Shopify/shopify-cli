# typed: ignore
# frozen_string_literal: true
module Theme
  class Project < ShopifyCLI::ProjectType
    require Project.project_filepath("messages/messages")
    register_messages(Theme::Messages::MESSAGES)
  end

  class Command < ShopifyCLI::Command::ProjectCommand
    subcommand :Init, "init", Project.project_filepath("commands/init")
    subcommand :Serve, "serve", Project.project_filepath("commands/serve")
    subcommand :Pull, "pull", Project.project_filepath("commands/pull")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Delete, "delete", Project.project_filepath("commands/delete")
    subcommand :Check, "check", Project.project_filepath("commands/check")
    subcommand :Publish, "publish", Project.project_filepath("commands/publish")
    subcommand :Package, "package", Project.project_filepath("commands/package")
    subcommand :LanguageServer, "language-server", Project.project_filepath("commands/language_server")
  end
  ShopifyCLI::Commands.register("Theme::Command", "theme")

  module Forms
    autoload :ConfirmStore, Project.project_filepath("forms/confirm_store")
    autoload :Select, Project.project_filepath("forms/select")
  end

  module UI
    autoload :SyncProgressBar, Project.project_filepath("ui/sync_progress_bar")
  end
end
