require "shopify_cli"

module ShopifyCLI
  module Commands
    class Feedback < ShopifyCLI::Command
      def call(*)
        system("open", "https://github.com/Shopify/shopify-cli/issues/new")
      end

      def open_github(ctx)
        open_link(ctx)
      end

      def open_link(ctx, suffix = "", remote: "origin")
        if (repo = github_remote(ctx, remote))
          system("open", "#{repo.url}/#{suffix}")
        end
      end
    end
  end
end
