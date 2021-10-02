# frozen_string_literal: true
require "pathname"
require "json"

module Theme
  class Command
    class Package < ShopifyCLI::Command::SubCommand
      THEME_DIRECTORIES = %w[
        assets
        config
        layout
        locales
        sections
        snippets
        templates
      ]

      def call(args, _name)
        path = args.first || "."

        check_prereq_command("zip")
        zip_name = theme_name(path) + ".zip"
        zip(zip_name, path, THEME_DIRECTORIES)
        @ctx.done(@ctx.message("theme.package.done", zip_name))
      end

      def self.help
        ShopifyCLI::Context.message("theme.package.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def check_prereq_command(command)
        cmd_path = @ctx.which(command)
        @ctx.abort(@ctx.message("theme.package.error.prereq_command_required", command)) if cmd_path.nil?
      end

      def zip(zip_name, path, files)
        @ctx.system("zip", "-r", zip_name, *files, chdir: path)
      end

      def theme_name(path)
        settings_schema = Pathname.new(path).join("config/settings_schema.json")
        @ctx.abort(@ctx.message("theme.package.error.missing_config")) unless settings_schema.file?

        content = settings_schema.read
        theme_info = JSON.parse(content).find { |section| section["name"] == "theme_info" }
        theme_name = theme_info&.dig("theme_name")
        @ctx.abort(@ctx.message("theme.package.error.missing_theme_name")) unless theme_name

        [theme_name, theme_info["theme_version"]].compact.join("-")
      end
    end
  end
end
