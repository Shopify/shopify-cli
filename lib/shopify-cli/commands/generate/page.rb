require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Page < ShopifyCli::Task
        def call(ctx, args)
          ctx.puts(self.class.help) if args.empty?
          name = args.first
          project = ShopifyCli::Project.current
          app_type = ShopifyCli::AppTypeRegistry[project.config["app_type"].to_sym]
          ctx.system("#{app_type.generate[:page]} #{name}")
        end

        def self.help
          <<~HELP
            Generate a page
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate <pagename>}}
          HELP
        end
      end
    end
  end
end
