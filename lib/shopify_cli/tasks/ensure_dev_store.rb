require "shopify_cli"

module ShopifyCLI
  module Tasks
    class EnsureDevStore < ShopifyCLI::Task
      def call(ctx)
        @ctx = ctx
        return ctx.abort(ctx.message(
          "core.tasks.ensure_dev_store.could_not_verify_store", project.env.shop
        )) if shop.nil?
        return if shop["transferDisabled"] == true
        return unless CLI::UI::Prompt.confirm(
          ctx.message("core.tasks.ensure_dev_store.convert_to_dev_store", project.env.shop)
        )
        ShopifyCLI::PartnersAPI.query(ctx, "convert_dev_to_test_store", input: {
          organizationID: shop["orgID"].to_i,
          shopId: shop["shopId"],
        })
        ctx.puts(ctx.message("core.tasks.ensure_dev_store.transfer_disabled", project.env.shop))
      end

      private

      def project
        @project ||= ShopifyCLI::Project.current
      end

      def shop
        @shop ||= begin
          current_domain = project.env.shop
          ShopifyCLI::PartnersAPI::Organizations.fetch_all(@ctx).map do |org|
            org["stores"].find do |store|
              store["orgID"] = org["id"]
              store["shopDomain"] == current_domain
            end
          end.compact.first
        end
      end
    end
  end
end
