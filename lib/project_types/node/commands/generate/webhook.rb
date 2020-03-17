require 'shopify_cli'
require 'json'
module Node
  module Commands
    class Generate
      class Webhook < ShopifyCli::SubCommand
        def call(args, _name)
          selected_type = args.first
          schema = ShopifyCli::Helpers::SchemaParser.new(
            schema: ShopifyCli::Tasks::Schema.call(@ctx)
          )
          enum = schema['WebhookSubscriptionTopic']
          webhooks = schema.get_names_from_enum(enum)
          unless selected_type && webhooks.include?(selected_type)
            selected_type = CLI::UI::Prompt.ask('What type of webhook would you like to create?') do |handler|
              webhooks.each do |type|
                handler.option(type) { type }
              end
            end
          end
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating webhook: #{selected_type}") do |spinner|
            Node::Commands::Generate.run_generate("./node_modules/.bin/generate-node-app webhook #{selected_type}", selected_type, @ctx)
            spinner.update_title("{{green:#{selected_type}}} generated in server/server.js")
          end
          spin_group.wait
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