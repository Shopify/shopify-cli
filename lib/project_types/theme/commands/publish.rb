# frozen_string_literal: true
require "shopify-cli/theme/theme"

module Theme
  class Command
    class Publish < ShopifyCli::SubCommand
      def call(args, *)
        theme = if (theme_id = args.first)
          ShopifyCli::Theme::Theme.new(@ctx, id: theme_id)
        else
          Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.publish.select"),
            exclude_roles: ["live", "development", "demo"],
          ).theme
        end

        theme.publish
        @ctx.done(@ctx.message("theme.publish.done", theme.preview_url))
      rescue ShopifyCli::API::APIRequestNotFoundError
        @ctx.puts(@ctx.message("theme.publish.not_found", theme.id))
      end

      def self.help
        ShopifyCli::Context.message("theme.publish.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
