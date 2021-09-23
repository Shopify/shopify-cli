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
        consent = check_application_url(app["applicationUrl"], url)
        constructed_urls = construct_redirect_urls(app["redirectUrlWhitelist"], url, callback_url)
        return if url == app["applicationUrl"]
        ShopifyCLI::PartnersAPI.query(@ctx, "update_dashboard_urls", input: {
          applicationUrl: consent ? url : app["applicationUrl"],
          redirectUrlWhitelist: constructed_urls, apiKey: api_key
        })
        @ctx.puts(@ctx.message("core.tasks.update_dashboard_urls.updated"))
      rescue
        @ctx.puts(@ctx.message("core.tasks.update_dashboard_urls.update_error", ShopifyCLI::TOOL_NAME))
        raise
      end

      def check_application_url(application_url, new_url)
        return false if application_url.match(new_url)
        CLI::UI::Prompt.confirm(@ctx.message("core.tasks.update_dashboard_urls.update_prompt"))
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
