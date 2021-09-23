require "shopify_cli"
require "json"
module Rails
  class Command
    class Generate
      class Webhook
        class << self
          def start(ctx, args)
            selected_type = args.first
            schema = ShopifyCLI::AdminAPI::Schema.get(ctx)
            webhooks = schema.get_names_from_type("WebhookSubscriptionTopic")
            unless selected_type && webhooks.include?(selected_type)
              selected_type = CLI::UI::Prompt.ask(ctx.message("rails.generate.webhook.select")) do |handler|
                webhooks.each do |type|
                  handler.option(type) { type }
                end
              end
            end
            spin_group = CLI::UI::SpinGroup.new
            spin_group.add(ctx.message("rails.generate.webhook.selected", selected_type)) do |spinner|
              Rails::Command::Generate.run_generate(generate_command(selected_type, ctx), selected_type, ctx)
              spinner.update_title("{{green:#{selected_type}}} config/initializers/shopify_app.rb")
            end
            spin_group.wait
          end

          def help
            ShopifyCLI::Context.message("rails.generate.webhook.help", ShopifyCLI::TOOL_NAME)
          end

          def generate_command(selected_type, ctx)
            parts = selected_type.downcase.split("_")
            host = ShopifyCLI::Project.current.env.host
            selected_type = parts[0..-2].join("_") + "/" + parts[-1]
            command = ctx.windows? ? "ruby bin\\rails" : "bin/rails"
            "#{command} g shopify_app:add_webhook -t #{selected_type} -a #{host}/webhooks/#{selected_type.downcase}"
          end
        end
      end
    end
  end
end
