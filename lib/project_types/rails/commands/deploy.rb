# frozen_string_literal: true
require "shopify_cli"

module Rails
  class Command
    class Deploy < ShopifyCli::SubCommand
      prerequisite_task ensure_project_type: :rails

      autoload :Heroku, Project.project_filepath("commands/deploy/heroku")

      HEROKU = "heroku"

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when HEROKU
          Rails::Command::Deploy::Heroku.start(@ctx)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        ShopifyCli::Context.message("rails.deploy.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("rails.deploy.extended_help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
