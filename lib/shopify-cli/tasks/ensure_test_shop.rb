require 'shopify_cli'

module ShopifyCli
  module Tasks
    class EnsureTestShop < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        return ctx.puts("Couldn't verify your shop #{project.env.shop}") if shop.nil?
        return if shop['transferDisabled'] == true
        return unless CLI::UI::Prompt.confirm("Do you want to convert #{project.env.shop} to a test shop."\
                                " This will enable you to install your app on this store.")
        ShopifyCli::PartnersAPI.query(ctx, 'convert_dev_to_test_store', input: {
          organizationID: shop['orgID'].to_i,
          shopId: shop['shopId'],
        })
        ctx.puts("{{v}} Transfer has been disabled on #{project.env.shop}.")
      end

      private

      def project
        @project ||= ShopifyCli::Project.current
      end

      def shop
        @shop ||= begin
          current_domain = project.env.shop
          Helpers::Organizations.fetch_all(@ctx).map do |org|
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
