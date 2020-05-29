require 'shopify_cli'

module ShopifyCli
  module Tasks
    class CreateApiClient < ShopifyCli::Task
      VALID_APP_TYPES = %w(public custom)

      def call(ctx, org_id:, title:, app_url:, type:)
        resp = ShopifyCli::PartnersAPI.query(
          ctx,
          'create_app',
          org: org_id.to_i,
          title: title,
          type: type,
          app_url: app_url,
          redir: [OAuth::REDIRECT_HOST]
        )

        user_errors = resp["data"]["appCreate"]["userErrors"]
        if !user_errors.nil? && user_errors.any?
          ctx.abort(user_errors.map { |err| "#{err['field']} #{err['message']}" }.join(", "))
        end

        resp["data"]["appCreate"]["app"]
      end
    end
  end
end
