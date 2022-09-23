# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "project_types/theme/commands/common/shop_helper"

module Theme
  class Command
    class Publish < ShopifyCLI::Command::SubCommand
      include Common::ShopHelper

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-f", "--force") { flags[:force] = true }
      end

      def call(args, *)
        theme = if (theme_id = args.first)
          ShopifyCLI::Theme::Theme.new(@ctx, id: theme_id)
        else
          form = Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.publish.select", shop),
            exclude_roles: ["live", "development", "demo"],
            cmd: :publish
          )
          return unless form
          form.theme
        end

        return unless Forms::ConfirmStore.ask(
          @ctx,
          [],
          title: @ctx.message("theme.publish.confirm", theme.name, theme.shop),
          force: options.flags[:force],
        ).confirmed?

        theme.publish
        @ctx.done(@ctx.message("theme.publish.done", theme.preview_url))
      rescue ShopifyCLI::API::APIRequestNotFoundError
        @ctx.puts(@ctx.message("theme.publish.not_found", theme.id))
      end

      def self.help
        ShopifyCLI::Context.message("theme.publish.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
