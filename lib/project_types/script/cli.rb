# frozen_string_literal: true

module Script
  class Project < ShopifyCLI::ProjectType
    hidden_feature(feature_set: :script_project)

    require Project.project_filepath("messages/messages")
    register_messages(Script::Messages::MESSAGES)
  end

  # define/autoload project specific Commands
  class Command < ShopifyCLI::Command::ProjectCommand
    hidden_feature(feature_set: :script_project)
    subcommand :Create, "create", Project.project_filepath("commands/create")
    subcommand :Push, "push", Project.project_filepath("commands/push")
    subcommand :Connect, "connect", Project.project_filepath("commands/connect")
    subcommand :Javy, "javy", Project.project_filepath("commands/javy")
  end
  ShopifyCLI::Commands.register("Script::Command", "script")

  module Loaders
    autoload :Project, Script::Project.project_filepath("loaders/project")
    autoload :SpecificationHandler, Script::Project.project_filepath("loaders/specification_handler")
  end

  class ScriptProjectError < StandardError; end
end
