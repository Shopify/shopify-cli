# frozen_string_literal: true
require "shopify-cli/theme/theme"
require "shopify-cli/theme/development_theme"
require "shopify-cli/theme/uploader"

module Theme
  class Command
    class Push < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("-n", "--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-u", "--unpublished") { flags[:unpublished] = true }
        parser.on("-j", "--json") { flags[:json] = true }
        parser.on("-a", "--allow-live") { flags[:allow_live] = true }
        parser.on("-p", "--publish") { flags[:publish] = true }

        # Only used for the config.yml, can be removed once usage is gone
        parser.on("--env=ENV") { |env| flags[:env] = env }
      end

      def call(args, _name)
        root = args.first || "."
        environment = options.flags[:env] || "development"
        config = ShopifyCli::Theme::Config.from_path(root, environment: environment)
        delete = !options.flags[:nodelete]

        theme = if (theme_id = options.flags[:theme_id])
          ShopifyCli::Theme::Theme.new(@ctx, config, id: theme_id)
        elsif options.flags[:development]
          theme = ShopifyCli::Theme::DevelopmentTheme.new(@ctx, config)
          theme.ensure_exists!
          theme
        elsif options.flags[:unpublished]
          name = CLI::UI::Prompt.ask(@ctx.message("theme.push.name"), allow_empty: false)
          theme = ShopifyCli::Theme::Theme.new(@ctx, config, name: name, role: "unpublished")
          theme.create
          theme
        else
          Forms::Select.ask(
            @ctx,
            [],
            title: @ctx.message("theme.push.select"),
            config: config,
          ).theme
        end

        if theme.live? && !options.flags[:allow_live]
          return unless CLI::UI::Prompt.confirm(@ctx.message("theme.push.live"))
        end

        uploader = ShopifyCli::Theme::Uploader.new(@ctx, theme)
        begin
          uploader.start_threads
          if options.flags[:json]
            uploader.upload_theme!(delete: delete)
            puts(JSON.generate(theme: theme.to_h))
          else
            CLI::UI::Frame.open(@ctx.message("theme.push.info.pushing", theme.name, theme.id, theme.shop)) do
              uploader.upload_theme_with_progress_bar!(delete: delete)
            end

            if options.flags[:publish]
              theme.publish
              @ctx.done(@ctx.message("theme.publish.done", theme.preview_url))
            else
              @ctx.done(@ctx.message("theme.push.done", theme.preview_url, theme.editor_url))
            end
          end

          @ctx.done(@ctx.message("theme.push.done", theme.preview_url, theme.editor_url))
        rescue ShopifyCli::API::APIRequestNotFoundError
          @ctx.abort(@ctx.message("theme.push.theme_not_found", theme.id))
        ensure
          uploader.shutdown
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.push.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
