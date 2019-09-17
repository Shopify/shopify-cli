module ShopifyCli
  module Tasks
    class UpdateWhitelistURL < ShopifyCli::Task

      def call(ctx, url: url)
        @ctx = ctx
        @app = ShopifyCli::Tasks::GetApp.call(@ctx)
        @url = ShopifyCli::Tasks::Tunnel.call(@ctx)
        puts @app
      end

      def check_urls
        whitelist_input = @app['redirectUrlWhitelist'].map do |url|
          # 'https://d1ea5a3e.ngrok.io' only a-f0-9
          if match = url.match(/https:\/\/([a-z0-9\-]+\.ngrok\.io)(.*)/)
            "https://#{new_url}#{match[2]}"
          else
            url
          end
        end
      end

      def mutation(urls)
        <<~QUERY
            mutation appUpdate($input: AppCreateInput!) {
              appUpdate(input: $input) {
                app {
                  apiKey
                  apiSecretKeys {
                    secret
                    createdAt
                  }
                  #{urls}
                }
                userErrors {
                  message
                  field
                }
              }
            }
        QUERY
      end

      def perform_mutation
        ShopifyCli::Helpers::PartnersAPI.query(@ctx, mutation, input: {redirectUrlWhitelist: [@url]})
      end
    end
  end
end
