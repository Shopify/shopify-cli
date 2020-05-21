require 'shopify_cli'

module ShopifyCli
  module Tasks
    class EnsureTestShop < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        return ctx.puts(ctx.message('core.tasks.ensure_test_shop.could_not_verify_shop', project.env.shop)) if shop.nil?
        return if shop['transferDisabled'] == true
        return unless CLI::UI::Prompt.confirm(
          ctx.message('core.tasks.ensure_test_shop.convert_dev_to_test_store', project.env.shop)
        )
        ShopifyCli::PartnersAPI.query(ctx, 'convert_dev_to_test_store', input: {
          organizationID: shop['orgID'].to_i,
          shopId: shop['shopId'],
        })
        ctx.puts(ctx.message('core.tasks.ensure_test_shop.transfer_disabled', project.env.shop))
      end

      private

      def project
        @project ||= ShopifyCli::Project.current
      end

      def shop
        @shop ||= begin
          current_domain = project.env.shop
          ShopifyCli::PartnersAPI::Organizations.fetch_all(@ctx).map do |org|
            org['stores'].find do |store|
              store['orgID'] = org['id']
              store['shopDomain'] == current_domain
            end
          end.compact.first
        end
      end
    end
  end
end
