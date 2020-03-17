require 'shopify_cli'

module Node
  module Commands
    class Generate
      class Page < ShopifyCli::SubCommand
        PAGE_TYPES = {
          'empty-state' => './node_modules/.bin/generate-node-app empty-state-page',
          'two-column' => './node_modules/.bin/generate-node-app two-column-page',
          'annotated' => './node_modules/.bin/generate-node-app settings-page',
          'list' => './node_modules/.bin/generate-node-app list-page',
        }

        options do |parser, flags|
          parser.on('--type=TYPE') do |t|
            flags[:type] = t.downcase
          end
        end

        def call(args, _name)
          name = args.first
          flag = options.flags[:type]
          unless name
            @ctx.puts(self.class.help)
            return
          end

          selected_type = if flag
            unless PAGE_TYPES.key?(flag)
              @ctx.abort("Invalid page type.")
            end
            PAGE_TYPES[flag]
          else
            CLI::UI::Prompt.ask("Which template would you like to use?") do |handler|
              PAGE_TYPES.each do |key, value|
                handler.option(key) { value }
              end
            end
          end

          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{selected_type} page...") do |spinner|
            Node::Commands::Generate.run_generate(
              "#{selected_type} #{name}", name, @ctx
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
