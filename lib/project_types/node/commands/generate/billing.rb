require 'shopify_cli'

module Node
  module Commands
    class Generate
      class Billing < ShopifyCli::SubCommand
        BILLING_TYPES = {
          'recurring-billing' => './node_modules/.bin/generate-node-app recurring-billing',
          'one-time-billing' => './node_modules/.bin/generate-node-app one-time-billing',
        }
        def call(args, _name)
          project = ShopifyCli::Project.current
          selected_type = BILLING_TYPES[args[1]]
          unless selected_type
            selected_type = CLI::UI::Prompt.ask('How would you like to charge for your app?') do |handler|
              BILLING_TYPES.each do |key, value|
                handler.option(key) { value }
              end
            end
          end
          billing_type_name = BILLING_TYPES.key(selected_type)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{billing_type_name} code ...") do |spinner|
            Node::Commands::Generate.run_generate(
              selected_type, billing_type_name, @ctx
            )
            spinner.update_title(
              "{{green:#{billing_type_name} generated in server/server.js"
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