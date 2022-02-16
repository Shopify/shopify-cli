# frozen_string_literal: true
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/ignore_filter"
require "shopify_cli/theme/include_filter"
require "shopify_cli/theme/syncer"
require "project_types/theme/conversions/include_glob"
require "project_types/theme/conversions/ignore_glob"

module Theme
  class Command
    class Pull < ShopifyCLI::Command::SubCommand
      recommend_default_ruby_range

      options do |parser, flags|
        Conversions::IncludeGlob.register(parser)
        Conversions::IgnoreGlob.register(parser)

        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
        parser.on("-l", "--live") { flags[:live] = true }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-o", "--only=PATTERN", Conversions::IncludeGlob) do |pattern|
          flags[:includes] ||= []
          flags[:includes] += pattern
        end
        parser.on("-x", "--ignore=PATTERN", Conversions::IgnoreGlob) do |pattern|
          flags[:ignores] ||= []
          flags[:ignores] += pattern
        end
      end

      def call(args, _name)
        root = first_arg(args, options)
        delete = !options.flags[:nodelete]
        theme = find_theme(root, **options.flags)
        return if theme.nil?

        include_filter = ShopifyCLI::Theme::IncludeFilter.new(options.flags[:includes])
        ignore_filter = ShopifyCLI::Theme::IgnoreFilter.from_path(root)
        ignore_filter.add_patterns(options.flags[:ignores]) if options.flags[:ignores]

        syncer = ShopifyCLI::Theme::Syncer.new(@ctx, theme: theme,
                                               include_filter: include_filter,
                                               ignore_filter: ignore_filter)
        begin
          syncer.start_threads
          CLI::UI::Frame.open(@ctx.message("theme.pull.pulling", theme.name, theme.id, theme.shop)) do
            UI::SyncProgressBar.new(syncer).progress(:download_theme!, delete: delete)
          end
          @ctx.done(@ctx.message("theme.pull.done"))
        rescue ShopifyCLI::API::APIRequestNotFoundError
          @ctx.abort(@ctx.message("theme.pull.theme_not_found", "##{theme.id}"))
        ensure
          syncer.shutdown
        end
      end

      def self.help
        ShopifyCLI::Context.message("theme.pull.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def first_arg(args, options)
        first = args.first
        return "." if first.nil?

        glob_parameters = [options.flags[:includes], options.flags[:ignores]].flatten.compact
        return "." if glob_parameters.include?(first)

        first
      end

      def find_theme(root, theme_id: nil, theme: nil, live: nil, development: nil, **_args)
        if theme_id
          @ctx.warn(@ctx.message("theme.pull.deprecated_themeid"))
          return ShopifyCLI::Theme::Theme.new(@ctx, root: root, id: theme_id)
        end

        if theme
          selected_theme = ShopifyCLI::Theme::Theme.find_by_identifier(@ctx, root: root, identifier: theme)
          return selected_theme || @ctx.abort(@ctx.message("theme.pull.theme_not_found", theme))
        end

        if live
          return ShopifyCLI::Theme::Theme.live(@ctx, root: root)
        end

        if development
          dev_theme = ShopifyCLI::Theme::DevelopmentTheme.find(@ctx, root: root)
          return dev_theme || @ctx.abort(@ctx.message("theme.pull.theme_not_found", dev_theme.name))
        end

        select_theme(root)
      end

      def select_theme(root)
        form = Forms::Select.ask(
          @ctx,
          [],
          title: @ctx.message("theme.pull.select"),
          root: root,
        )
        form&.theme
      end
    end
  end
end
