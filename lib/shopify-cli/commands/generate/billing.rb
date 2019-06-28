require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate
      class Billing < ShopifyCli::Task
        def call(ctx, args)
          ctx.puts(self.class.help) if args.empty?
          project = ShopifyCli::Project.current

          # temporary check until we build for rails
          if project.app_type == ShopifyCli::AppTypes::Rails
            raise(ShopifyCli::Abort, 'This feature is not yet available for Rails apps')
          end

          type = CLI::UI::Prompt.ask('Which kind of billing?') do |handler|
            handler.option('recurring billing') { :billing_recurring }
            handler.option('one-time billing') { :billing_one_time }
          end
          ShopifyCli::Commands::Generate.run_generate(project.app_type.generate[type], type, ctx)
          ctx.puts("{{green:✔︎}} Generating Billing code: #{type}")
        end

        def self.help
          <<~HELP
            Enable charging for your app. This command generates the necessary code to call Shopify’s billing API.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate billing}}
          HELP
        end
      end
    end
  end
end
