require 'shopify_cli'
require 'json'
module Node
  module Commands
    class Generate
      class Webhook < ShopifyCli::SubCommand
        def call(args, _name)
          selected_type = args.first
          shop = Project.current.env.shop || get_shop(@ctx)
          schema = ShopifyCli::AdminAPI::Schema.get(@ctx, shop)
          webhooks = schema.get_names_from_type('WebhookSubscriptionTopic')
          unless selected_type && webhooks.include?(selected_type)
            selected_type = CLI::UI::Prompt.ask(@ctx.message('node.generate.webhook.type_select')) do |handler|
              webhooks.each do |type|
                handler.option(type) { type }
              end
            end
          end
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('node.generate.webhook.generating', selected_type)) do |spinner|
            Node::Commands::Generate.run_generate("./node_modules/.bin/generate-node-app webhook #{selected_type}",
              selected_type, @ctx)
            spinner.update_title(@ctx.message('node.generate.webhook.generated', selected_type))
          end
          spin_group.wait
        end

        def self.help
          ShopifyCli::Context.message('node.generate.webhook.help', ShopifyCli::TOOL_NAME)
        end

        private

        def get_shop(ctx)
          res = ShopifyCli::Tasks::SelectOrgAndShop.call(ctx)
          domain = res[:shop_domain]
          Project.current.env.update(ctx, :shop, domain)
          domain
        end
      end
    end
  end
end
