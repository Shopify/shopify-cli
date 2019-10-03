require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Project < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--type=TYPE') do |t|
            flags[:type] = t
          end
        end

        def call(args, _name)
          name = args[1]
          flag = options.flags[:type]
          puts AppTypeRegistry.each
          if !name || name.include?('--')
            @ctx.puts(self.class.help)
            return
          end

          app_type = if options.flags[:type]
            flag.downcase.to_sym
          else
            CLI::UI::Prompt.ask('What type of app project would you like to create?') do |handler|
              AppTypeRegistry.each do |identifier, type|
                handler.option(type.description) { identifier }
              end
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
