require 'shopify_cli'
require 'json'
module ShopifyCli
  module Commands
    class Generate
      class Webhook < ShopifyCli::Task
        include ShopifyCli::Helpers::SchemaParser

        def call(ctx, args)
          # TODO: Add check for file after authenticate shopify is complete
          selected_type = args.first
          schema = ShopifyCli::Tasks::GetSchema.call(ctx)
          enum = get_types_by_name(schema, 'WebhookSubscriptionTopic')
          webhooks = get_names_from_enum(enum)

          unless selected_type
            selected_type = CLI::UI::Prompt.ask('What type of webhook would you like to create?') do |handler|
              webhooks.each do |type|
                handler.option(type) { type }
              end
            end
          end

          project = ShopifyCli::Project.current
          app_type = ShopifyCli::AppTypeRegistry[project.config["app_type"].to_sym]
          ctx.exec("#{app_type.generate[:webhook]} #{selected_type}")
        end

        def self.help
          <<~HELP
            Generate webhook scaffolding
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook <type>}}
          HELP
        end
      end
    end
  end
end
