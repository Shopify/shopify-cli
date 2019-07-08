require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Page < ShopifyCli::Task
        def call(ctx, args)
          if args.empty?
            ctx.puts(self.class.help)
            return
          end
          project = ShopifyCli::Project.current

          name = args.first
          spin_group = CLI::UI::SpinGroup.new
          spin_group.add("Generating #{name}") do |spinner|
            ShopifyCli::Commands::Generate.run_generate("#{project.app_type.generate[:page]} #{name}", name, ctx)
            spinner.update_title(project.app_type.page_information(name))
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
