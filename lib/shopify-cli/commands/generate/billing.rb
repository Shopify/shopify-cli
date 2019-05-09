require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Billing < ShopifyCli::Task
        def call(ctx, args)
          ctx.puts(self.class.help) if args.empty?
          name = args.first
          project = ShopifyCli::Project.current
          app_type = ShopifyCli::AppTypeRegistry[project.config["app_type"].to_sym]
          ctx.exec("#{app_type.generate[:billing]} #{type}")
        end

        def self.help
          <<~HELP
            Bootstrap an app.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create <appname>}}
          HELP
        end
      end
    end
  end
end
