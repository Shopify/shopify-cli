require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Project < ShopifyCli::SubCommand
        def call(args, _name)
          if args.empty?
            @ctx.puts(self.class.help)
            return
          end
          name = args[1]
          app_type = CLI::UI::Prompt.ask('What type of app project would you like to create?') do |handler|
            AppTypeRegistry.each do |identifier, type|
              handler.option(type.description) { identifier }
            end
          end

          ShopifyCli::Tasks::Tunnel.call(@ctx)

          AppTypeRegistry.check_dependencies(app_type, @ctx)

          AppTypeRegistry.build(app_type, name, @ctx)
          ShopifyCli::Project.write(@ctx, app_type)
          @ctx.puts("{{*}} Whitelist your development URLs in the Partner Dashboard:
          {{underline:https://github.com/Shopify/shopify-app-cli#whitelisting-app-redirection-urls}}")
        end

        def self.help
          <<~HELP
            Create a new app project.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}
          HELP
        end
      end
    end
  end
end
