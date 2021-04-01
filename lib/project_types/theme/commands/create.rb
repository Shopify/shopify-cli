# frozen_string_literal: true
require "json"
module Theme
  module Commands
    class Create < ShopifyCli::SubCommand
      TEMPLATE_DIRS = ["assets", "config", "layout", "locales", "templates"]

      SETTINGS_DATA = <<~SETTINGS_DATA
          {
            "current": "Default",
            "presets": {
              "Default": { }
            }
          }
        SETTINGS_DATA

        SETTINGS_SCHEMA = <<~SETTINGS_SCHEMA
          [
            {
              "name": "theme_info",
              "theme_name": "Shopify CLI template theme",
              "theme_version": "1.0.0",
              "theme_author": "Shopify",
              "theme_documentation_url": "https://github.com/Shopify/shopify-app-cli",
              "theme_support_url": "https://github.com/Shopify/shopify-app-cli/issues"
            }
          ]
        SETTINGS_SCHEMA

        options do |parser, flags|
        parser.on("--name=NAME") { |t| flags[:title] = t }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        build(form.name)
        ShopifyCli::Project.write(@ctx,
          project_type: "theme",
          organization_id: nil) # private apps are different
        @ctx.done(@ctx.message("theme.create.info.created", form.name, ShopifyCli::AdminAPI.get_shop(@ctx), @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message("theme.create.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def build(name)
        @ctx.abort(@ctx.message("theme.create.duplicate_theme")) if @ctx.dir_exist?(name)
        @ctx.mkdir_p(name)
        @ctx.chdir(name)
        spin = CLI::UI::SpinGroup.new
        spin.add(@ctx.message("theme.create.creating_theme", name)) do |spinner|
          create_directories
          spinner.update_title(@ctx.message("theme.create.info.dir_created"))
        rescue => e
            @ctx.chdir("..")
            @ctx.rm_rf(name)
            @ctx.abort(@ctx.message("theme.create.failed", e))
        end
        spin.wait
      end

      def create_directories
        TEMPLATE_DIRS.each { |dir| @ctx.mkdir_p(dir) }

        @ctx.write("config/settings_data.json", SETTINGS_DATA)
        @ctx.write("config/settings_schema.json", SETTINGS_SCHEMA)
      end
    end
  end
end
