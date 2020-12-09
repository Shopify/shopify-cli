require 'shopify_cli'
require 'json'
module Node
  module Commands
    class Generate
      class Webhook < ShopifyCli::SubCommand
        def call(args, _name)
          selected_type = args.first
          schema = ShopifyCli::AdminAPI::Schema.get(@ctx)
          webhooks = schema.get_names_from_type('WebhookSubscriptionTopic')
          unless selected_type && webhooks.include?(selected_type)
            selected_type =
              CLI::UI::Prompt.ask(@ctx.message('node.generate.webhook.type_select')) do |handler|
                webhooks.each { |type| handler.option(type) { type } }
              end
          end

          generate_path = File.join(ShopifyCli::Project.current.directory, 'node_modules/.bin/generate-node-app')
          generate_path = "\"#{generate_path}\""

          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('node.generate.webhook.generating', selected_type)) do |spinner|
            Node::Commands::Generate.run_generate("#{generate_path} webhook #{selected_type}", selected_type, @ctx)
            spinner.update_title(@ctx.message('node.generate.webhook.generated', selected_type))
          end
          spin_group.wait
        end

        def self.help
          ShopifyCli::Context.message('node.generate.webhook.help', ShopifyCli::TOOL_NAME)
        end
      end
    end
  end
end
