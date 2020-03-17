require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Page < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--type=TYPE') do |t|
            flags[:type] = t.downcase
          end
        end

        def call(args, _name)
          project = ShopifyCli::Project.current
          # temporary check until we build for rails
          if project.app_type == ShopifyCli::AppTypes::Rails
            @ctx.error("This feature is not yet available for Rails apps")
          end
          types = project.app_type.page_types
          name = args.first
          flag = options.flags[:type]
          unless name
            @ctx.puts(self.class.help)
            return
          end

          selected_type = if flag
            unless types.key?(flag)
              @ctx.error("Invalid page type.")
            end
            types[flag]
          else
            CLI::UI::Prompt.ask("Which template would you like to use?") do |handler|
              types.each do |key, value|
                handler.option(key) { value }
              end
            end
          end

          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{types.key(selected_type)} page...") do |spinner|
            ShopifyCli::Commands::Generate.run_generate(
              "#{project.app_type.generate[selected_type]} #{name}", name, @ctx
            )
            spinner.update_title("{{green: #{name}}} generated in pages/#{name}")
          end
          spin_group.wait
        end

        def self.help
          <<~HELP
            Generate a new page in your app with the specified name. New files are generated inside the project’s “/pages” directory.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate page <pagename>}}
          HELP
        end
      end
    end
  end
end
