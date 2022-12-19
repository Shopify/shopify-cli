# frozen_string_literal: true

require "shopify_cli/theme/theme"
require "shopify_cli/theme/syncer"
require "project_types/theme/commands/common/root_helper"

module Theme
  class Command
    class Share < ShopifyCLI::Command::SubCommand
      include Common::RootHelper

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-f", "--force") { flags[:force] = true }
      end

      def call(_args, name)
        root = root_value(options, name)
        return unless valid_theme_directory?(root)

        theme = create_theme(root)

        upload(theme)

        @ctx.done(done_message(theme))
      end

      def self.help
        tool = ShopifyCLI::TOOL_NAME
        @ctx.message("theme.share.help", tool, tool)
      end

      private

      def create_theme(root)
        ShopifyCLI::Theme::Theme.create_unpublished(@ctx, root: root)
      end

      def upload(theme)
        syncer = ShopifyCLI::Theme::Syncer.new(@ctx, theme: theme)
        syncer.start_threads

        CLI::UI::Frame.open(upload_message(theme)) do
          UI::SyncProgressBar.new(syncer).progress(:upload_theme!)
        end

        raise ShopifyCLI::AbortSilent if syncer.has_any_error?
      ensure
        syncer.shutdown
      end

      def upload_message(theme)
        @ctx.message("theme.share.upload", theme.name, theme.id, theme.shop)
      end

      def done_message(theme)
        @ctx.message("theme.share.done", theme.name, theme.preview_url, theme.editor_url)
      end
    end
  end
end
