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
          name = args.first
          project = ShopifyCli::Project.current
          ctx.system("#{project.app_type.generate[:page]} #{name}")
        end

        def self.help
          <<~HELP
            Generate a new page in your app with the specified name. New files are generated inside the project’s "/pages" directory.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate <pagename>}}
          HELP
        end
      end
    end
  end
end
