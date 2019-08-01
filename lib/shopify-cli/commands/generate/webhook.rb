require 'shopify_cli'
require 'json'
module ShopifyCli
  module Commands
    class Generate
      class Webhook < ShopifyCli::Task
        def call(ctx, args)
          project = ShopifyCli::Project.current
          selected_type = args.first
          schema = ShopifyCli::Helpers::SchemaParser.new(
            schema: ShopifyCli::Tasks::Schema.call(ctx)
          )
          enum = schema['WebhookSubscriptionTopic']
          webhooks = schema.get_names_from_enum(enum)
          unless selected_type
            selected_type = CLI::UI::Prompt.ask('What type of webhook would you like to create?') do |handler|
              webhooks.each do |type|
                handler.option(type) { type }
              end
            end
          end

          app_type = project.app_type
          ShopifyCli::Commands::Generate.run_generate(app_type.generate_command(selected_type), selected_type, ctx)
          ctx.puts("{{v}} Generating webhook: #{selected_type}")
        end

        def self.help
          <<~HELP
            Generate and register a new webhook that listens for the specified Shopify store event.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook <type>}}
          HELP
        end
      end
    end
  end
end
