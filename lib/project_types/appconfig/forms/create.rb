require 'uri'

module AppConfig
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :name, :organization_id, :type, :app_url, :allowed_redirection_urls

      def ask
        self.name ||= CLI::UI::Prompt.ask(ctx.message('appconfig.forms.create.app_name'))
        self.type = ask_type
        install_app = false # TODO: Add flow to install app on dev stores
        self.app_url ||= CLI::UI::Prompt.ask(ctx.message('appconfig.forms.create.app_url'))
        self.allowed_redirection_urls = ask_redirection_urls
        self.organization_id = ask_organization_id
      end

      private

      def ask_type
        if type.nil?
          return CLI::UI::Prompt.ask(ctx.message('appconfig.forms.create.app_type.select')) do |handler|
            handler.option(ctx.message('appconfig.forms.create.app_type.select_public')) { 'public' }
            handler.option(ctx.message('appconfig.forms.create.app_type.select_custom')) { 'custom' }
          end
        end

        unless ShopifyCli::Tasks::CreateApiClient::VALID_APP_TYPES.include?(type)
          ctx.abort(ctx.message('node.forms.create.error.invalid_app_type', type))
        end
        ctx.puts(ctx.message('node.forms.create.app_type.selected', type))
        type
      end

      def ask_redirection_urls
        url_string = allowed_redirection_urls ||
          CLI::UI::Prompt.ask(ctx.message('appconfig.forms.create.allowed_redirection_urls'))
        urls = url_string.split(",")
        return urls if contains_valid_urls?(urls)
        ctx.abort(ctx.message('appconfig.forms.create.error.invalid_redirection_urls', url_string))
      end

      def contains_valid_urls?(urls)
        valid_urls = true
        urls.each do |url|
          valid_urls = false if url !~ URI.regexp
        end

        valid_urls
      end

      def ask_organization_id
        if organization_id.nil?
          res = ShopifyCli::Tasks::SelectOrgAndShop.call(
            ctx,
            organization_id: organization_id,
            shop_domain: nil,
            skip_shop: !install_app
          )

          res[:organization_id]
        end

        organization_id
      end
    end
  end
end
