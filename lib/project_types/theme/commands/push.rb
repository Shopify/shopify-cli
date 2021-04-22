# frozen_string_literal: true
require "shopify-cli/theme/config"
require "shopify-cli/theme/theme"
require "shopify-cli/theme/development_theme"
require "shopify-cli/theme/uploader"

module Theme
  class Command
    class Push < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--nodelete") { flags[:nodelete] = true }
        parser.on("-i", "--themeid=ID") { |theme_id| flags[:theme_id] = theme_id }
        parser.on("-d", "--development") { flags[:development] = true }
        parser.on("-j", "--json") { flags[:json] = true }

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
        else
          ask_select_theme(config)
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

            @ctx.done(@ctx.message("theme.push.done", theme.preview_url, theme.editor_url))
          end
        rescue ShopifyCli::API::APIRequestNotFoundError
          @ctx.abort(@ctx.message("theme.push.theme_not_found", theme.id))
        ensure
          uploader.shutdown
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.push.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def ask_select_theme(config)
        CLI::UI::Prompt.ask(@ctx.message("theme.push.select")) do |handler|
          ShopifyCli::Theme::Theme.all(@ctx, config).each do |theme|
            handler.option("#{theme.name} {{green:[#{theme.role}]}}") { theme }
          end
        end
      end
    end
  end
end
