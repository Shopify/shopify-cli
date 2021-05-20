module ShopifyCli
  module Tasks
    class EnsureLoopbackURL < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        api_key = Project.current.env.api_key
        result = ShopifyCli::PartnersAPI.query(ctx, "get_app_urls", apiKey: api_key)
        loopback = IdentityAuth::REDIRECT_HOST
        app = result["data"]["app"]
        urls = app["redirectUrlWhitelist"]
        if urls.grep(/#{loopback}/).empty?
          with_loopback = urls.push(loopback)
          ShopifyCli::PartnersAPI.query(@ctx, "update_dashboard_urls", input: {
            redirectUrlWhitelist: with_loopback, apiKey: api_key
          })
        end
      end
    end
  end
end
