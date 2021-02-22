# lib/project_types/foo/commands/create.rb
module AppConfig
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--name=NAME') { |t| flags[:name] = t }
        parser.on('--organization_id=ID') { |url| flags[:organization_id] = url }
        parser.on('--type=APPTYPE') { |url| flags[:type] = url }
        parser.on('--app_url=MYAPPDOMAIN') { |url| flags[:app_url] = url }
        parser.on('--allowed_redirection_urls=MYAPPREDIRECTIONDOMAIN') { |t| flags[:allowed_redirection_urls] = t }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        ShopifyCli::Project.write(
          @ctx,
          project_type: 'appconfig',
          organization_id: form.organization_id,
        )

        api_client = ShopifyCli::Tasks::CreateApiClient.call(
          @ctx,
          org_id: form.organization_id,
          title: form.name,
          type: form.type,
          app_url: form.app_url,
          redir: form.allowed_redirection_urls
        )

        partners_url = ShopifyCli::PartnersAPI.partners_url_for(form.organization_id, api_client['id'], local_debug?)

        # TODO: install app on dev stores

        @ctx.puts(ShopifyCli::Context.message('appconfig.create.created', partners_url))
        unless ShopifyCli::Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message('apps.create.info.install', partners_url, form.name))
        end
      end

      def self.help
        ShopifyCli::Context.message('appconfig.create.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end

      private

      def local_debug?
        @ctx.getenv(ShopifyCli::PartnersAPI::LOCAL_DEBUG)
      end
    end
  end
end
