# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "project_types/theme/commands/common/shop_helper"

module Theme
  class Command
    class Delete < ShopifyCLI::Command::SubCommand
      include Common::ShopHelper

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-a", "--show-all") { flags[:show_all] = true }
        parser.on("-f", "--force") { flags[:force] = true }
      end

      def call(args, _name)
        themes = if options.flags[:development]
          [ShopifyCLI::Theme::DevelopmentTheme.new(@ctx)]
        elsif args.any?
          args.map { |id| ShopifyCLI::Theme::Theme.new(@ctx, id: id) }
        else
          form = Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.delete.select", shop),
            exclude_roles: ["live"],
            include_foreign_developments: options.flags[:show_all],
            cmd: :delete
          )
          return unless form
          [form.theme]
        end

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
    end
  end
end
