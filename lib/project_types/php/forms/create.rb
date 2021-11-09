require "uri"

module PHP
  module Forms
    class Create < ShopifyCLI::Form
      flag_arguments :name, :organization_id, :shop_domain, :type

      def ask
        self.name ||= CLI::UI::Prompt.ask(ctx.message("php.forms.create.app_name"))
        self.name = format_name
        self.type = ask_type
        res = ShopifyCLI::Tasks::SelectOrgAndShop.call(ctx, organization_id: organization_id, shop_domain: shop_domain)
        self.organization_id = res[:organization_id]
        self.shop_domain = res[:shop_domain]
      end

      private

      def format_name
        formatted_name = name.downcase.split(" ").join("_")

        if formatted_name.include?("shopify")
          ctx.abort(ctx.message("php.forms.create.error.invalid_app_name"))
        end
        formatted_name
      end

      def ask_type
        if type.nil?
          return CLI::UI::Prompt.ask(ctx.message("php.forms.create.app_type.select")) do |handler|
            handler.option(ctx.message("php.forms.create.app_type.select_public")) { "public" }
            handler.option(ctx.message("php.forms.create.app_type.select_custom")) { "custom" }
          end
        end

        unless ShopifyCLI::Tasks::CreateApiClient::VALID_APP_TYPES.include?(type)
          ctx.abort(ctx.message("php.forms.create.error.invalid_app_type", type))
        end
        ctx.puts(ctx.message("php.forms.create.app_type.selected", type))
        type
      end
    end
  end
end
