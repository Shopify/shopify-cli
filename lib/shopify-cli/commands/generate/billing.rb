require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Billing < ShopifyCli::Task
        def call(ctx, args)
          ctx.puts(self.class.help) if args.empty?
          project = ShopifyCli::Project.current
          app_type = ShopifyCli::AppTypeRegistry[project.config["app_type"].to_sym]
          type = CLI::UI::Prompt.ask('Which kind of billing?') do |handler|
            handler.option('recurring billing') { :billing_recurring }
            handler.option('one time billing') { :billing_one_time }
          end
          ctx.exec(app_type.generate[type])
        end

        def self.help
          <<~HELP
            Bootstrap an app.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} add billing <appname>}}
          HELP
        end
      end
    end
  end
end
