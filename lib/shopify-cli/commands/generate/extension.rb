require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Extension < ShopifyCli::SubCommand
        def call(args, _name)
          project = ShopifyCli::Project.current
          extension_types = {
            'marketing-activities-extension' => :marketing_activities_extension
          }
          selected_type = extension_types[args[1]]
          app_type = project.app_type
          unless selected_type
            selected_type = CLI::UI::Prompt.ask('Which extension would you like to generate?') do |handler|
              extension_types.each do |key, value|
                handler.option(key) { value }
              end
            end
          end
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{extension_types.key(selected_type)} code ...") do |spinner|
            ShopifyCli::Commands::Generate.run_generate(
              project.app_type.generate[selected_type], selected_type, @ctx
            )
            spinner.update_title(
              "#{extension_types.key(selected_type)} generated in #{app_type.extension_location(selected_type)}"
            )
          end
          spin_group.wait
        end

        def self.help
          <<~HELP
            Generate a new extension as documented in https://help.shopify.com/en/api/embedded-apps/app-extensions.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate extension}}
          HELP
        end
      end
    end
  end
end
