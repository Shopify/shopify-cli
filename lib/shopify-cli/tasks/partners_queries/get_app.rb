module ShopifyCli
  module Tasks
    class GetApp < ShopifyCli::Task

      def call(ctx)
        @ctx = ctx
        result = ShopifyCli::Helpers::PartnersAPI.query(
          @ctx, query(Project.current.env.api_key)
        )
        puts result
        result['data']
      end

      def query(apiKey)
        <<~QUERY
            query getApp {
              app(apiKey: 20) {
                apiKey 
                redirectUrlWhitelist
              }
            }
        QUERY
      end
    end
  end
end
