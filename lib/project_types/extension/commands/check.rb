# typed: ignore
# frozen_string_literal: true
require "theme_check"

module Extension
  class Command
    class Check < ExtensionCommand
      class CheckOptions < ShopifyCLI::Options
        def initialize(ctx, theme_check)
          super()
          @theme_check = theme_check
          @ctx = ctx
        end

        def parse(_options_block, args)
          # Check if .theme-check.yml exists, or if another -C has been passed on the command line
          unless args.include?("-C") || @ctx.file_exist?(".theme-check.yml")
            args += ["-C", ":theme_app_extension"]
          end
          @theme_check.parse(args)
        end
      end

      def initialize(*)
        super
        if project.specification_identifier == "THEME_APP_EXTENSION"
          @theme_check = ThemeCheck::Cli.new
          self.options = CheckOptions.new(@ctx, @theme_check)
        end
      end

      def call(*)
        if project.specification_identifier == "THEME_APP_EXTENSION"
          @theme_check.run
        else
          @ctx.abort(@ctx.message("check.unsupported", project.specification_identifier))
        end
      end

      def self.help
        ShopifyCLI::Context.message("check.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
