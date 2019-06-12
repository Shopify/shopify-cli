require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Billing < ShopifyCli::Task
        def call(ctx, args)
          ctx.puts(self.class.help) if args.empty?
          project = ShopifyCli::Project.current
          type = CLI::UI::Prompt.ask('Which kind of billing?') do |handler|
            handler.option('recurring billing') { :billing_recurring }
            handler.option('one time billing') { :billing_one_time }
          end
          ctx.system(project.app_type.generate[type])
        end

        def self.help
          <<~HELP
            Generate billing scaffold
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}
          HELP
        end
      end
    end
  end
end
