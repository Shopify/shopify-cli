# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/ignore_filter"
require "shopify_cli/theme/include_filter"
require "shopify_cli/theme/syncer"
require "project_types/theme/commands/common/root_helper"
require "project_types/theme/commands/common/shop_helper"
require "project_types/theme/conversions/include_glob"
require "project_types/theme/conversions/ignore_glob"

module Theme
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      include Common::ShopHelper
      include Common::RootHelper

      recommend_default_ruby_range

      options do |parser, flags|
        Conversions::IncludeGlob.register(parser)
        Conversions::IgnoreGlob.register(parser)

        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
        parser.on("-l", "--live") { flags[:live] = true }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-u", "--unpublished") { flags[:unpublished] = true }
        parser.on("-j", "--json") { flags[:json] = true }
        parser.on("-a", "--allow-live") { flags[:allow_live] = true }
        parser.on("-p", "--publish") { flags[:publish] = true }
        parser.on("-s", "--stable") { flags[:stable] = true }
        parser.on("-o", "--only=PATTERN", Conversions::IncludeGlob) do |pattern|
          flags[:includes] ||= []
          flags[:includes] |= pattern
        end
        parser.on("-x", "--ignore=PATTERN", Conversions::IgnoreGlob) do |pattern|
          flags[:ignores] ||= []
          flags[:ignores] |= pattern
        end
        parser.on("-f", "--force") { flags[:force] = true }
        parser.on("--development-theme-id=DEVELOPMENT_THEME_ID") do |development_theme_id|
          flags[:development_theme_id] = development_theme_id.to_i
        end
      end

      def call(_args, name)
        root = root_value(options, name)
        return unless valid_theme_directory?(root)

        development_theme_id = options.flags[:development_theme_id]
        ShopifyCLI::DB.set(development_theme_id: development_theme_id) unless development_theme_id.nil?

        delete = !options.flags[:nodelete]
        theme = find_theme(root, **options.flags)
        return if theme.nil?

        if theme.live? && !options.flags[:allow_live]
          question = @ctx.message("theme.push.live")
          question += @ctx.message("theme.push.theme", theme.name, theme.id) if options.flags[:live]
          return unless CLI::UI::Prompt.confirm(question)
        end

        include_filter = ShopifyCLI::Theme::IncludeFilter.new(root, options.flags[:includes])
        ignore_filter = ShopifyCLI::Theme::IgnoreFilter.from_path(root)
        ignore_filter.add_patterns(options.flags[:ignores]) if options.flags[:ignores]

        syncer = ShopifyCLI::Theme::Syncer.new(@ctx, theme: theme,
          include_filter: include_filter,
          ignore_filter: ignore_filter,
          stable: options.flags[:stable])
        begin
          syncer.start_threads
          if options.flags[:json]
            syncer.standard_reporter.disable!
            syncer.upload_theme!(delete: delete)
          else
            CLI::UI::Frame.open(@ctx.message("theme.push.info.pushing", theme.name, theme.id, theme.shop)) do
              UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delete: delete)
            end
          end
          push_completion_handler(theme, syncer.has_any_error?)
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

      def push_completion_handler(theme, has_errors)
        if options.flags[:json]
          output = { theme: theme.to_h }
          output[:warning] = @ctx.message("theme.push.with_errors") if has_errors

          puts(JSON.generate(output))
        elsif options.flags[:publish]
          theme.publish
          return @ctx.done(@ctx.message("theme.publish.done", theme.preview_url)) unless has_errors
          @ctx.warn(@ctx.message("theme.publish.done_with_errors", theme.preview_url))
        else
          return @ctx.done(@ctx.message("theme.push.done", theme.preview_url, theme.editor_url)) unless has_errors
          @ctx.warn(@ctx.message("theme.push.done_with_errors", theme.preview_url, theme.editor_url))
        end
        raise ShopifyCLI::AbortSilent if has_errors
      end

      def find_theme(root, theme_id: nil, theme: nil, live: nil, development: nil, unpublished: nil, **_args)
        if theme_id
          @ctx.warn(@ctx.message("theme.push.deprecated_themeid"))
          return ShopifyCLI::Theme::Theme.new(@ctx, root: root, id: theme_id)
        end

        if live
          return ShopifyCLI::Theme::Theme.live(@ctx, root: root)
        end

        if development
          return ShopifyCLI::Theme::DevelopmentTheme.find_or_create!(@ctx, root: root)
        end

        if unpublished
          name = theme || ask_theme_name
          return ShopifyCLI::Theme::Theme.create_unpublished(@ctx, root: root, name: name)
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
          title: @ctx.message("theme.push.select", shop),
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
