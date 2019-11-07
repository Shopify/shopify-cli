module ShopifyCli
  module Tasks
    class UpdateDashboardURLS < ShopifyCli::Task
      NGROK_REGEX = /https:\/\/([a-z0-9\-]+\.ngrok\.io)(.*)/

      def call(ctx, url:)
        @ctx = ctx
        project = ShopifyCli::Project.current
        app_type = project.app_type
        api_key = project.env.api_key
        result = Helpers::PartnersAPI.query(ctx, 'get_app_urls', apiKey: api_key)
        callback = app_type.callback_url
        app = result['data']['app']
        consent = check_application_url(app['applicationUrl'], url)
        constructed_urls = construct_redirect_urls(app['redirectUrlWhitelist'], url, callback)
        return if url == app['applicationUrl']
        ShopifyCli::Helpers::PartnersAPI.query(@ctx, 'update_dashboard_urls', input: {
          applicationUrl: consent ? url : app['applicationUrl'],
          redirectUrlWhitelist: constructed_urls, apiKey: api_key
        })
        @ctx.puts("{{v}} Whitelist URLS updated in Partners Dashboard}}")
      end

      def check_application_url(application_url, new_url)
        return false if application_url.match(NGROK_REGEX) && new_url.match(NGROK_REGEX)
        CLI::UI::Prompt.confirm('Do you want to update your application url?')
      end

      def construct_redirect_urls(urls, new_url, callback)
        if urls.grep(/#{new_url}#{callback}/).empty?
          urls.push("#{new_url}#{callback}")
        end
        urls.map do |url|
          if (match = url.match(NGROK_REGEX))
            "#{new_url}#{match[2]}"
          else
            url
          end
        end
      end
    end
  end
end
