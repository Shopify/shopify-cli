require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Billing < ShopifyCli::SubCommand
        def call(args, _name)
          project = ShopifyCli::Project.current
          billing_types = {
            'recurring-billing' => :billing_recurring,
            'one-time-billing' => :billing_one_time,
          }
          selected_type = billing_types[args[1]]
          # temporary check until we build for rails
          if project.app_type == ShopifyCli::AppTypes::Rails
            @ctx.error('This feature is not yet available for Rails apps')
          end
          unless selected_type
            selected_type = CLI::UI::Prompt.ask('How would you like to charge for your app?') do |handler|
              billing_types.each do |key, value|
                handler.option(key) { value }
              end
            end
          end
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{billing_types.key(selected_type)} code ...") do |spinner|
            ShopifyCli::Commands::Generate.run_generate(
              project.app_type.generate[selected_type], selected_type, @ctx
            )
            spinner.update_title(
              "{{green:#{billing_types.key(selected_type)}}} generated in server/server.js"
            )
          end
          spin_group.wait
        end

        def self.help
          <<~HELP
            Enable charging for your app. This command generates the necessary code to call Shopify’s billing API.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing recurring-billing | one-time-billing}}
          HELP
        end
      end
    end
  end
end
