require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Project < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--title=TITLE') { |t| title[:title] = t }
          parser.on('--type=TYPE') { |t| flags[:type] = t.downcase.to_sym }
          parser.on('--app_url=APPURL') { |url| flags[:app_url] = url }
          parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
          parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |url| flags[:shop_domain] = url }
        end

        def call(args, _name)
          form = Forms::CreateApp.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) if form.nil?

          AppTypeRegistry.check_dependencies(form.type, @ctx)
          AppTypeRegistry.build(form.type, form.name, @ctx)
          ShopifyCli::Project.write(@ctx, form.type)

          api_client = Tasks::CreateApiClient.call(
            @ctx,
            org_id: form.organization_id,
            title: form.title,
            app_url: form.app_url,
          )

          Helpers::EnvFile.new(
            api_key: api_client["apiKey"],
            secret: api_client["apiSecretKeys"].first["secret"],
            shop: form.shop_domain,
            scopes: 'write_products,write_customers,write_draft_orders',
          ).write(@ctx)
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
