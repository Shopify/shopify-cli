module ShopifyCli
  module Tasks
    class UpdateWhitelistURL < ShopifyCli::Task

      def call(ctx, url: url)
        @ctx = ctx
        api_key = Project.current.env.api_key
        result = Helpers::PartnersAPI.query(ctx, 'get_app_urls', apiKey: api_key)
        app = result['data']['app']
        whitelist_urls = check_urls(app['redirectUrlWhitelist'], url)
        return if whitelist_urls == app['redirectUrlWhitelist']
        puts ShopifyCli::Helpers::PartnersAPI.query(@ctx, 'update_whitelisturls', input: {
          redirectUrlWhitelist: whitelist_urls, apiKey: api_key
        })
      end

      def check_urls(urls, new_url)
        urls.map do |url|
          # 'https://d1ea5a3e.ngrok.io' only a-f0-9
          if match = url.match(/https:\/\/([a-z0-9\-]+\.ngrok\.io)(.*)/)
            "#{new_url}#{match[2]}"
          else
            url
          end
        end
      end
    end
  end
end
