require 'shopify_cli'

module Node
  module Commands
    class Generate
      class Page < ShopifyCli::SubCommand
        PAGE_TYPES = {
          'empty-state' => %w[./node_modules/.bin/generate-node-app empty-state-page],
          'two-column' => %w[./node_modules/.bin/generate-node-app two-column-page],
          'annotated' => %w[./node_modules/.bin/generate-node-app settings-page],
          'list' => %w[./node_modules/.bin/generate-node-app list-page]
        }

        options { |parser, flags| parser.on('--type=TYPE') { |t| flags[:type] = t.downcase } }

        def call(args, _name)
          name = args.first
          flag = options.flags[:type]
          unless name
            @ctx.puts(self.class.help)
            return
          end

          selected_type =
            if flag
              @ctx.abort(@ctx.message('node.generate.page.error.invalid_page_type')) unless PAGE_TYPES.key?(flag)
              PAGE_TYPES[flag]
            else
              CLI::UI::Prompt.ask(@ctx.message('node.generate.page.type_select')) do |handler|
                PAGE_TYPES.each { |key, value| handler.option(key) { value } }
              end
            end
          page_type_name = PAGE_TYPES.key(selected_type)
          selected_type[0] = File.join(ShopifyCli::Project.current.directory, selected_type[0])
          selected_type[0] = "\"#{selected_type[0]}\""
          selected_type = selected_type.join(' ')

          spin_group = CLI::UI::SpinGroup.new
          spin_group.add(@ctx.message('node.generate.page.generating', page_type_name)) do |spinner|
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
