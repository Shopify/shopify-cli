# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/ignore_filter"
require "shopify_cli/theme/syncer"

module Theme
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      options do |parser, flags|
        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-u", "--unpublished") { flags[:unpublished] = true }
        parser.on("-j", "--json") { flags[:json] = true }
        parser.on("-a", "--allow-live") { flags[:allow_live] = true }
        parser.on("-p", "--publish") { flags[:publish] = true }
        parser.on("-x", "--ignore=PATTERN") do |pattern|
          flags[:ignores] ||= []
          flags[:ignores] << pattern
        end
      end

      def call(args, _name)
        root = args.first || "."
        delete = !options.flags[:nodelete]

        theme = if (theme_id = options.flags[:theme_id])
          ShopifyCLI::Theme::Theme.new(@ctx, root: root, id: theme_id)
        elsif options.flags[:development]
          theme = ShopifyCLI::Theme::DevelopmentTheme.new(@ctx, root: root)
          theme.ensure_exists!
          theme
        elsif options.flags[:unpublished]
          name = CLI::UI::Prompt.ask(@ctx.message("theme.push.name"), allow_empty: false)
          theme = ShopifyCLI::Theme::Theme.new(@ctx, root: root, name: name, role: "unpublished")
          theme.create
          theme
        else
          form = Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.push.select"),
            root: root,
          )
          return unless form
          form.theme
        end

        if theme.live? && !options.flags[:allow_live]
          return unless CLI::UI::Prompt.confirm(@ctx.message("theme.push.live"))
        end

        ignore_filter = ShopifyCLI::Theme::IgnoreFilter.from_path(root)
        ignore_filter.add_patterns(options.flags[:ignores]) if options.flags[:ignores]

        syncer = ShopifyCLI::Theme::Syncer.new(@ctx, theme: theme, ignore_filter: ignore_filter)
        begin
          syncer.start_threads
          if options.flags[:json]
            syncer.upload_theme!(delete: delete)
            puts(JSON.generate(theme: theme.to_h))
          else
            CLI::UI::Frame.open(@ctx.message("theme.push.info.pushing", theme.name, theme.id, theme.shop)) do
              UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delete: delete)
            end

            if options.flags[:publish]
              theme.publish
              @ctx.done(@ctx.message("theme.publish.done", theme.preview_url))
            else
              @ctx.done(@ctx.message("theme.push.done", theme.preview_url, theme.editor_url))
            end
          end
        rescue ShopifyCLI::API::APIRequestNotFoundError
          @ctx.abort(@ctx.message("theme.push.theme_not_found", theme.id))
        ensure
          syncer.shutdown
        end
      end

      def self.help
        ShopifyCLI::Context.message("theme.push.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
