# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/ignore_filter"
require "shopify_cli/theme/include_filter"
require "shopify_cli/theme/syncer"

module Theme
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      recommend_default_node_range
      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
        parser.on("-l", "--live") { flags[:live] = true }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-u", "--unpublished") { flags[:unpublished] = true }
        parser.on("-j", "--json") { flags[:json] = true }
        parser.on("-a", "--allow-live") { flags[:allow_live] = true }
        parser.on("-p", "--publish") { flags[:publish] = true }
        parser.on("-o", "--only=PATTERN") { |pattern| flags[:includes] = pattern }
        parser.on("-x", "--ignore=PATTERN") do |pattern|
          flags[:ignores] ||= []
          flags[:ignores] << pattern
        end
      end

      def call(args, _name)
        root = args.first || "."
        delete = !options.flags[:nodelete]
        theme = find_theme(root, **options.flags)
        return if theme.nil?

        if theme.live? && !options.flags[:allow_live]
          question = @ctx.message("theme.push.live")
          question += @ctx.message("theme.push.theme", theme.name, theme.id) if options.flags[:live]
          return unless CLI::UI::Prompt.confirm(question)
        end

        include_filter = ShopifyCLI::Theme::IncludeFilter.new(options.flags[:includes])
        ignore_filter = ShopifyCLI::Theme::IgnoreFilter.from_path(root)
        ignore_filter.add_patterns(options.flags[:ignores]) if options.flags[:ignores]

        syncer = ShopifyCLI::Theme::Syncer.new(@ctx, theme: theme,
                                               include_filter: include_filter,
                                               ignore_filter: ignore_filter)
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
          raise ShopifyCLI::AbortSilent if syncer.has_any_error?
        ensure
          syncer.shutdown
        end
      rescue ShopifyCLI::API::APIRequestNotFoundError
        @ctx.abort(@ctx.message("theme.push.theme_not_found", "##{theme.id}"))
      end

      def self.help
        ShopifyCLI::Context.message("theme.push.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def find_theme(root, theme_id: nil, theme: nil, live: nil, development: nil, unpublished: nil, **_args)
        if theme_id
          @ctx.warn(@ctx.message("theme.push.deprecated_themeid"))
          return ShopifyCLI::Theme::Theme.new(@ctx, root: root, id: theme_id)
        end

        if live
          return ShopifyCLI::Theme::Theme.live(@ctx, root: root)
        end

        if development
          new_theme = ShopifyCLI::Theme::DevelopmentTheme.new(@ctx, root: root)
          new_theme.ensure_exists!
          return new_theme
        end

        if unpublished
          name = theme || ask_theme_name
          new_theme = ShopifyCLI::Theme::Theme.new(@ctx, root: root, name: name, role: "unpublished")
          new_theme.create
          return new_theme
        end

        if theme
          selected_theme = ShopifyCLI::Theme::Theme.find_by_identifier(@ctx, root: root, identifier: theme)
          return selected_theme || @ctx.abort(@ctx.message("theme.push.theme_not_found", theme))
        end

        select_theme(root)
      end

      def ask_theme_name
        CLI::UI::Prompt.ask(@ctx.message("theme.push.name"), allow_empty: false)
      end

      def select_theme(root)
        form = Forms::Select.ask(
          @ctx,
          [],
          title: @ctx.message("theme.push.select"),
          root: root,
        )
        form&.theme
      end

      def themes(root)
        ShopifyCLI::Theme::Theme.all(@ctx, root: root)
      end
    end
  end
end
