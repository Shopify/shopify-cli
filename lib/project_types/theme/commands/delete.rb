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
      end

      def call(args, _name)
        themes = find_themes(args: args, **options.flags)
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

      def find_themes(args:, development: false, show_all: false, **_options)
        if args.any?
          return args.map { |id| ShopifyCLI::Theme::Theme.new(@ctx, id: id) }
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

      def confirm?(theme)
        Forms::ConfirmStore.ask(
          @ctx,
          [],
          title: @ctx.message("theme.delete.confirm", theme.name, theme.shop),
          force: options.flags[:force],
        ).confirmed?
      end
    end
  end
end
