require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Page < ShopifyCli::Task
        include ShopifyCli::Helpers::GenerateResources
        def call(ctx, args)
          if args.empty?
            ctx.puts(self.class.help)
            return
          end
          name = args.first
          project = ShopifyCli::Project.current
          run_generate("#{project.app_type.generate[:page]} #{name}", name, ctx)
          ctx.puts("{{green:✔︎}} Generating page: #{name}")
        end

        def self.help
          <<~HELP
            Generate a page
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate <pagename>}}
          HELP
        end
      end
    end
  end
end
