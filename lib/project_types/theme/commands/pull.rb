# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/ignore_filter"
require "shopify_cli/theme/syncer"

module Theme
  class Command
    class Pull < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-x", "--ignore=PATTERN") do |pattern|
          flags[:ignores] ||= []
          flags[:ignores] << pattern
        end
      end

      def call(args, _name)
        root = args.first || "."
        delete = !options.flags[:nodelete]

        theme = if (theme_id = options.flags[:theme_id])
          ShopifyCli::Theme::Theme.new(@ctx, root: root, id: theme_id)
        else
          form = Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.pull.select"),
            root: root,
          )
          return unless form
          form.theme
        end

        ignore_filter = ShopifyCli::Theme::IgnoreFilter.from_path(root)
        ignore_filter.add_patterns(options.flags[:ignores]) if options.flags[:ignores]

        syncer = ShopifyCli::Theme::Syncer.new(@ctx, theme: theme, ignore_filter: ignore_filter)
        begin
          syncer.start_threads
          CLI::UI::Frame.open(@ctx.message("theme.pull.pulling", theme.name, theme.id, theme.shop)) do
            UI::SyncProgressBar.new(syncer).progress(:download_theme!, delete: delete)
          end
          @ctx.done(@ctx.message("theme.pull.done"))
        rescue ShopifyCli::API::APIRequestNotFoundError
          @ctx.abort(@ctx.message("theme.pull.theme_not_found", theme.id))
        ensure
          syncer.shutdown
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.pull.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
