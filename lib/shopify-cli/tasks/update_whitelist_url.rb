module ShopifyCli
  module Tasks
    class UpdateWhitelistURL < ShopifyCli::Task
      def call(ctx, url:)
        @ctx = ctx
        project = ShopifyCli::Project.current
        app_type = project.app_type
        api_key = Project.current.env.api_key
        result = Helpers::PartnersAPI.query(ctx, 'get_app_urls', apiKey: api_key)
        callback = app_type.callback_url
        app = result['data']['app']
        whitelist_urls = check_urls(app['redirectUrlWhitelist'], url)
        with_callback = check_callback_url(whitelist_urls, url, callback)
        return if with_callback == app['redirectUrlWhitelist']
        ShopifyCli::Helpers::PartnersAPI.query(@ctx, 'update_whitelisturls', input: {
          applicationUrl: url,
          redirectUrlWhitelist: whitelist_urls, apiKey: api_key
        })
        @ctx.puts("{{v}} Whitelist URLS updated in Partners Dashboard}}")
      end

      def check_urls(urls, new_url)
        urls.map do |url|
          if (match = url.match(/https:\/\/([a-z0-9\-]+\.ngrok\.io)(.*)/))
            "#{new_url}#{match[2]}"
          else
            url
          end
        end
      end

      def check_callback_url(urls, new_url, callback)
        if urls.grep(/#{callback}/).empty?
          urls.push("#{new_url}#{callback}")
        else
          urls
        end
      end
    end
  end
end
