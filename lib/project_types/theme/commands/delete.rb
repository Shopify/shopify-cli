# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"

module Theme
  class Command
    class Delete < ShopifyCLI::Command::SubCommand
      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-a", "--show-all") { flags[:show_all] = true }
        parser.on("-f", "--force") { flags[:force] = true }
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
      end

      def call(_args, _name)
        themes = find_themes(**options.flags)
        return if themes.empty?

        deleted = 0
        themes.each do |theme|
          if theme.live?
            @ctx.puts(@ctx.message("theme.delete.live", theme.id))
            next
          elsif !confirm?(theme)
            next
          end
          theme.delete
          deleted += 1
        rescue ShopifyCLI::API::APIRequestNotFoundError
          @ctx.puts(@ctx.message("theme.delete.not_found", theme.id))
        end

        @ctx.done(@ctx.message("theme.delete.done", deleted))
      end

      def self.help
        ShopifyCLI::Context.message("theme.delete.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def confirm?(theme)
        Forms::ConfirmStore.ask(
          @ctx,
          [],
          title: @ctx.message("theme.delete.confirm", theme.name, theme.shop),
          force: options.flags[:force],
        ).confirmed?
      end

      def find_themes(theme: nil, development: nil, show_all: false, **_args)
        if theme
          selected_theme = ShopifyCLI::Theme::Theme.find_by_identifier(@ctx, identifier: theme)
          return [selected_theme] if selected_theme

          @ctx.abort(@ctx.message("theme.delete.theme_not_found", theme))
          return []
        end

        if development
          dev_theme = ShopifyCLI::Theme::DevelopmentTheme.find(@ctx)
          return [dev_theme] if dev_theme

          @ctx.abort(@ctx.message("theme.delete.no_development_theme_error"),
            @ctx.message("theme.delete.no_development_theme_resolution"))
          return []
        end

        select_theme(show_all)
      end

      def select_theme(show_all)
        form = Forms::Select.ask(
          @ctx,
          [],
          title: @ctx.message("theme.delete.select"),
          exclude_roles: ["live"],
          include_foreign_developments: show_all,
          cmd: :delete
        )
        return [] unless form
        [form.theme]
      end
    end
  end
end
