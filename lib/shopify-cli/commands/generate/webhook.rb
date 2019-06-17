require 'shopify_cli'
require 'json'
module ShopifyCli
  module Commands
    class Generate
      class Webhook < ShopifyCli::Task
        include ShopifyCli::Helpers::ErrorCodeMessages
        include ShopifyCli::Helpers::SchemaParser
        def call(ctx, args)
          selected_type = args.first
          schema = ShopifyCli::Tasks::Schema.call(ctx)
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
          app_type = project.app_type
          stat = ctx.system("#{app_type.generate[:webhook]} #{selected_type}")
          ctx.puts("{{green:✔︎}} Generated webhook: #{selected_type}")
          unless stat.success?
            raise(ShopifyCli::Abort, response(stat.exitstatus, selected_type))
          end
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
