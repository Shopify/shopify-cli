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
              @ctx.abort(@ctx.message('node.generate.page.error.invalid_page_type'))
            end
            PAGE_TYPES[flag]
          else
            CLI::UI::Prompt.ask(@ctx.message('node.generate.page.type_select')) do |handler|
              PAGE_TYPES.each do |key, value|
                handler.option(key) { value }
              end
            end
          end

          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('node.generate.page.generating', selected_type)) do |spinner|
            Node::Commands::Generate.run_generate("#{selected_type} #{name}", name, @ctx)
            spinner.update_title(@ctx.message('node.generate.page.generated', name, name))
          end
          spin_group.wait
        end

        def self.help
          ShopifyCli::Context.message('node.generate.page.help', ShopifyCli::TOOL_NAME)
        end
      end
    end
  end
end
