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
          selected_type = BILLING_TYPES[args[1]]
          unless selected_type
            selected_type = CLI::UI::Prompt.ask(@ctx.message('node.generate.billing.type_select')) do |handler|
              BILLING_TYPES.each do |key, value|
                handler.option(key) { value }
              end
            end
          end
          billing_type_name = BILLING_TYPES.key(selected_type)
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('node.generate.billing.generating', billing_type_name)) do |spinner|
            Node::Commands::Generate.run_generate(
              selected_type, billing_type_name, @ctx
            )
            spinner.update_title(@ctx.message('node.generate.billing.generated', billing_type_name))
          end
          spin_group.wait
        end

        def self.help
          ShopifyCli::Context.message('node.generate.billing.help', ShopifyCli::TOOL_NAME)
        end
      end
    end
  end
end