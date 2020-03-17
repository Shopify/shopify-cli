require 'shopify_cli'

module ShopifyCli
  module Tasks
    class CreateApiClient < ShopifyCli::Task
      def call(ctx, org_id:, title:, app_url:)
        resp = Helpers::PartnersAPI.query(
          ctx,
          'create_app',
          org: org_id.to_i,
          title: title,
          app_url: app_url,
          redir: [OAuth::REDIRECT_HOST]
        )

        user_errors = resp["data"]["appCreate"]["userErrors"]
        if !user_errors.nil? && user_errors.any?
          ctx.error(user_errors.map { |err| "#{err['field']} #{err['message']}" }.join(", "))
        end

        resp["data"]["appCreate"]["app"]
      end
    end
  end
end
