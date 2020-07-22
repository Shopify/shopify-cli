require 'shopify_cli'
require 'json'
module Rails
  module Commands
    class Generate
      class Webhook < ShopifyCli::SubCommand
        def call(args, _name)
          selected_type = args.first
          schema = ShopifyCli::AdminAPI::Schema.get(@ctx)
          webhooks = schema.get_names_from_type('WebhookSubscriptionTopic')
          unless selected_type && webhooks.include?(selected_type)
            selected_type = CLI::UI::Prompt.ask(@ctx.message('rails.generate.webhook.select')) do |handler|
              webhooks.each do |type|
                handler.option(type) { type }
              end
            end
          end
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('rails.generate.webhook.selected', selected_type)) do |spinner|
            Rails::Commands::Generate.run_generate(generate_command(selected_type), selected_type, @ctx)
            spinner.update_title("{{green:#{selected_type}}} config/initializers/shopify_app.rb")
          end
          spin_group.wait
        end

        def self.help
          ShopifyCli::Context.message('rails.generate.webhook.help', ShopifyCli::TOOL_NAME)
        end

        def generate_command(selected_type)
          parts = selected_type.downcase.split("_")
          host = ShopifyCli::Project.current.env.host
          selected_type = parts[0..-2].join("_") + "/" + parts[-1]
          command = @ctx.windows? ? "ruby bin\\rails" : "rails"
          "#{command} g shopify_app:add_webhook -t #{selected_type} -a #{host}/webhooks/#{selected_type.downcase}"
        end
      end
    end
  end
end
