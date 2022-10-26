# frozen_string_literal: true
require "pathname"
require "json"

module Theme
  class Command
    class Package < ShopifyCLI::Command::SubCommand
      recommend_default_ruby_range

      THEME_DIRECTORIES = %w[
        assets
        config
        layout
        locales
        sections
        snippets
        templates
        release-notes.md
      ]

      ZIP = "zip"
      SEVEN_ZIP = "7z"

      def call(args, _name)
        path = args.first || "."

        check_prereq_command
        zip_name = theme_name(path) + ".zip"

        zip(zip_name, path, THEME_DIRECTORIES)
        @ctx.done(@ctx.message("theme.package.done", zip_name))
      end

      def self.help
        ShopifyCLI::Context.message("theme.package.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def check_prereq_command
        @ctx.abort(@ctx.message("theme.package.error.prereq_command_required")) if command.nil?
      end

      def zip(zip_name, path, files)
        @ctx.system(command, command_flags, zip_name, *files, chdir: path)
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

      def command
        @command ||= if @ctx.which(ZIP)
          ZIP
        elsif @ctx.which(SEVEN_ZIP)
          SEVEN_ZIP
        end
      end

      def command_flags
        @command_flags ||= command == ZIP ? "-r" : "a"
      end
    end
  end
end
