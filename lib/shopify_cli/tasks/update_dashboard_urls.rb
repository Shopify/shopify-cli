module ShopifyCLI
  module Tasks
    class UpdateDashboardURLS < ShopifyCLI::Task
      NGROK_REGEX = /https:\/\/([a-z0-9\-]+\.ngrok\.io)(.*)/

      def call(ctx, url:, callback_url:)
        @ctx = ctx
        project = ShopifyCLI::Project.current
        api_key = project.env.api_key
        result = ShopifyCLI::PartnersAPI.query(ctx, "get_app_urls", apiKey: api_key)
        app = result["data"]["app"]

        constructed_urls = construct_redirect_urls(app["redirectUrlWhitelist"], url, callback_url)
        ShopifyCLI::PartnersAPI.query(@ctx, "update_dashboard_urls", input: {
          applicationUrl: url,
          redirectUrlWhitelist: constructed_urls,
          apiKey: api_key,
        })

        @ctx.puts(@ctx.message("core.tasks.update_dashboard_urls.updated"))
      rescue
        @ctx.puts(@ctx.message("core.tasks.update_dashboard_urls.update_error", ShopifyCLI::TOOL_NAME))
        raise
      end

      def construct_redirect_urls(urls, new_url, callback_url)
        new_urls = urls.map do |url|
          if (match = url.match(NGROK_REGEX))
            "#{new_url}#{match[2]}"
          else
            url
          end
        end
        if new_urls.grep(/#{new_url}#{callback_url}/).empty?
          new_urls.push("#{new_url}#{callback_url}")
        end
        new_urls.uniq
      end
    end
  end
end
