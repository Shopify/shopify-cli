# frozen_string_literal: true

require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "project_types/theme/commands/common/shop_helper"

module Theme
  class Command
    class Open < ShopifyCLI::Command::SubCommand
      include Common::ShopHelper

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
        parser.on("-l", "--live") { flags[:live] = true }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-e", "--editor") { flags[:editor] = true }
      end

      def call(_args, _name)
        theme = find_theme(**options.flags)

        @ctx.puts(@ctx.message("theme.open.details", theme.name, theme.preview_url, theme.editor_url))
        if options.flags[:editor]
          @ctx.open_browser_url!(theme.editor_url)
        else
          @ctx.open_browser_url!(theme.preview_url)
        end
      end

      def self.help
        ShopifyCLI::Context.message("theme.open.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      def find_theme(theme: nil, live: nil, development: nil, **_args)
        return theme_by_identifier(theme) if theme
        return live_theme if live
        return development_theme if development

        select_theme
      end

      def theme_by_identifier(identifier)
        theme = ShopifyCLI::Theme::Theme.find_by_identifier(@ctx, identifier: identifier)
        theme || not_found_error(identifier)
      end

      def development_theme
        theme = ShopifyCLI::Theme::DevelopmentTheme.find(@ctx)
        theme || not_found_error("development")
      end

      def live_theme
        ShopifyCLI::Theme::Theme.live(@ctx)
      end

      def not_found_error(identifier)
        @ctx.abort(@ctx.message("theme.open.theme_not_found", identifier))
      end

      def select_theme
        form = Forms::Select.ask(
          @ctx,
          [],
          title: @ctx.message("theme.open.select", shop),
          root: nil
        )
        form&.theme
      end
    end
  end
end
