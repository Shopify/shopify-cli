module ShopifyCli
  module Tasks
    class EnsureLoopbackURL < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        api_key = Project.current.env.api_key
        result = Helpers::PartnersAPI.query(ctx, 'get_app_urls', apiKey: api_key)
        loopback = OAuth::REDIRECT_HOST
        app = result['data']['app']
        urls = app['redirectUrlWhitelist']
        if urls.grep(/#{loopback}/).empty?
          with_loopback = urls.push(loopback)
          ShopifyCli::Helpers::PartnersAPI.query(@ctx, 'update_whitelisturls', input: {
            redirectUrlWhitelist: with_loopback, apiKey: api_key
          })
        end
      end
    end
  end
end
