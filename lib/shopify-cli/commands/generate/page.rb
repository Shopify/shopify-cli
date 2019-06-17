require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Page < ShopifyCli::Task
        include ShopifyCli::Helpers::ErrorCodeMessages
        def call(ctx, args)
          if args.empty?
            ctx.puts(self.class.help)
            return
          end
          name = args.first
          project = ShopifyCli::Project.current
          stat = ctx.system("#{project.app_type.generate[:page]} #{name}")
          ctx.puts("{{green:✔︎}} Generated page: #{name}")
          unless stat.success?
            raise(ShopifyCli::Abort, response(stat.exitstatus, name))
          end
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
